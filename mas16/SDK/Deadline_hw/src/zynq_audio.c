#include <stdio.h>
#include "xparameters.h"
#include "xil_io.h"
#include "audio.h"
#include "oled.h"
#include <stdlib.h>
#include <math.h>

/* Defining function prototype */
void init_timer();
/* Initialising global variables */
Xint16 audio_data[128];
unsigned int ret[128]={0};

/* Main function */
int main()
{
	register u16 var = 0, i = 0;
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
		init_timer();
		get_audio(audio_data);
		start_timer();
		/* Pass values to the hardware buffer/ram from get_audio module */
		for( i=0;i<128;i++)
		{
			Xil_Out32(XPAR_AUDIO_PROJECT_0_S_AXI_MEM0_BASEADDR + i*4 ,audio_data[i]);
		}
		/* Make 128th bit of input buffer high, before passing the values to FFT engine */
		Xil_Out32(XPAR_AUDIO_PROJECT_0_S_AXI_MEM0_BASEADDR + 128*4 ,1);
		/* Monitor the 128th bit to go high, before displaying on OLED */
		while (Xil_In32(XPAR_AUDIO_PROJECT_0_S_AXI_MEM0_BASEADDR + (128*4)!=1));
	
		/* Store the final values to be displayed on OLED */
		for( i=0;i<128;i++)
		{
			ret[i] = (Xil_In32(XPAR_AUDIO_PROJECT_0_S_AXI_MEM0_BASEADDR + i*4));
		}
		/* Display module */	
		for(var=0;var<128;var++){
		 		 oled_equalizer_buf[var]=(ret[var]);
		}
		stop_timer();
		OLED_Clear();
		OLED_Equalizer_128(oled_equalizer_buf);
	}
    return 0;
}
