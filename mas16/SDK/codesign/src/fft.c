#include <stdio.h>
#include <stdlib.h>
#include <math.h>

/* Defining Look up tables */
double theta_value[7] = {3.141593,1.570796,0.785398,0.392699,0.196350,0.098175,0.049087};
double theta_value_half[7] = {1.570796,0.785398,0.392699,0.196350,0.098175,0.049087,0.024544};

int fft(register double *data)
{
        register unsigned long n,mmax,m,j,istep,i;
        register double wtemp,wr,wpr,wpi,wi,theta;
        register double tempr,tempi;
        /* n denotes both real and imaginary part of the data */
        n=128;
        j=1;
        /* Bit reversal Technique */
        for (i=1;i<128;i=i+2) {
                if (j > i) {
                	    tempr=data[j];
                	    data[j]=data[i];
                	    data[i]=tempr;
                	    tempr=data[j+1];
                	    data[j+1]=data[i+1];
                	    data[i+1]=tempr;
                }
                m=64;
                while (m >= 2 && j > m) {
                        j = j-m;
                        m = (m>>1);
                }
                j =j+m;
        }
        mmax=2;
        int t=0;
        while (n > mmax) {
                istep=mmax << 1;
                theta=theta_value_half[t];
                wtemp=sin(theta);
                wpr = -2.0*wtemp*wtemp;
                theta=theta_value[t];
                wpi=sin(theta);
                wr=1.0;
                wi=0.0;
                for (m=1;m<mmax;m=m+2) {
                /* FFT algorithm */
                        for (i=m;i<=n;i=i+istep) {
                                j=i+mmax;
                                tempr=wr*data[j]-wi*data[j+1];
                                tempi=wr*data[j+1]+wi*data[j];
                                data[j]=data[i]-tempr;
                                data[j+1]=data[i+1]-tempi;
                                data[i] = data[i] + tempr;
                                data[i+1] =data[i+1] + tempi;
                        }
                        wr=(wtemp=wr)*wpr-wi*wpi+wr;
                        wi=wi*wpr+wtemp*wpi+wi;
                }
                mmax=istep;
                t=t+1;
        }
        return *data;
}
