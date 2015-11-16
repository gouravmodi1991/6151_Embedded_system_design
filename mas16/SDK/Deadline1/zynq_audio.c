/*
 * Author: Mahesh and Gourav
 * Audio processing application
 */

#include <stdio.h>
#include "audio.h"
#include "oled.h"
#include "sleep.h"
#include <stdlib.h>
#include <math.h>
#define NO_OF_SAMPLES 128
#define NO_OF_WINDOWS 8

/* Function prototype*/
void init_timer();
void start_timer();
void stop_timer();
int fft(double *data);

/* Initialising global variables */
signed long int LED[64]={0};
double audio_signal[NO_OF_SAMPLES] = {0.0};
double audio_data_fft[2*NO_OF_SAMPLES] = {0} ;
Xint16 audio_data[NO_OF_SAMPLES];
u32 window[NO_OF_WINDOWS][64]={{0}};
u32 noise[64]={0};
u32 noiseavg[64]={0};

/* Main function */
int main()
{
	register u16 Index=0, var=0, k=0;
	u8 *oled_equalizer_buf=(u8 *)malloc(128*sizeof(u8));
	Xil_Out32(OLED_BASE_ADDR,0xff);
	/* OLED Init */
	OLED_Init();
	IicConfig(XPAR_XIICPS_0_DEVICE_ID);
	/* Enable core clock for ADAU1761 */
	AudioPllConfig();
	AudioConfigure();
	xil_printf("ADAU1761 configured\n\r");


	/* Following block fetches the data, processes it and sends it to OLED screen*/
	while(1)
	{
		/* Sample input data */
		init_timer();
		start_timer();
		get_audio(audio_data);
		var=0;
		/* Convert data into sequences of alternate real and imaginary parts */
		for (k=0; k<256; k=k+2 ){
			audio_data_fft[k] = (double)audio_data[var];
			audio_data_fft[k+1] = 0 ;
			var=var+1;
		}
		 /* Invoke FFT function */
		 fft(audio_data_fft-1);
		 k=0;
		 /* Modulus function */
		 for(var=0;var<128;var=var+2){
			 window[(Index%8)][k]=((audio_data_fft[var]*audio_data_fft[var])+(audio_data_fft[var+1]*audio_data_fft[var+1]));
			 k=k+1;
		 }
		 /* Sliding window averaging, noise cancellation and thresholding */
		 if(Index>1023){
			 for(var=0;var<64;var++){
				 LED[var]=(((window[0][var]+window[1][var]+window[2][var]+window[3][var]+window[4][var]+window[5][var]+window[6][var]+window[7][var])>>3)-noiseavg[var]);
				 if(LED[var]<=0){
		 		    LED[var]=0;
		 		 }
		     }
		 /* Display on the OLED screen and thresholding */
		 	 for(var=0;var<64;var++){
		 		 oled_equalizer_buf[var]=(LED[var]>>18);
		 		 if(oled_equalizer_buf[var]>63){
		 			 oled_equalizer_buf[var]=63;
		 		 }
		 		 oled_equalizer_buf[127-var]=oled_equalizer_buf[var];
		 	 }
		 	 stop_timer();
		 	 OLED_Clear();
		 	 OLED_Equalizer_128(oled_equalizer_buf);
		 }
		 /* Calculate Noise */
		 else
		 {
			 for(var=0;var<64;var++){
				 noise[var]=noise[var]+window[Index%8][var];
			 }
			 if(Index%32==31){
				 for(var=0;var<64;var++){
					 noiseavg[var]=((noiseavg[var]+noise[var])>>5);
					 noise[var]=0;
				 }
			 }
			 if(Index==1023){
				 for(var=0;var<64;var++){
					 noiseavg[var]=(noiseavg[var]>>5);
				 }
			 }
		  }
		 Index++;
	 }
    return 0;
}
