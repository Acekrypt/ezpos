/***************************************************************************
 *   Copyright (C) 2006 by James Pruitt,,,   *
 *   pruittj@nas   *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.             *
 ***************************************************************************/


#ifdef HAVE_CONFIG_H
#include <config.h>
#endif

#include <stdio.h>
#include <stdlib.h>


int main(int argc, char *argv[])
{

        char x;
        char str [80];
        int value;
        int i;
        value = 0;
        i = 0;
        int linecnt;
        int testing;
        testing = 0;


        FILE *fpi=fopen(argv[1],"r");

        if (argv[1] == NULL ) {
                fprintf(stderr, "useage: %s <image name>\n", argv[0] );
                return EXIT_FAILURE;
        }

        if (fpi == NULL ) {
                printf("%s does not exist. Please enter the correct image file name.\n", argv[1]);
                return EXIT_FAILURE;
        }

        if (argv[2] != NULL ) {
                printf("Program is in test mode.\n");
                testing = 1;
                printf("argc is %d\n", argc);
                printf("argv is %s\n", argv[1]);
                printf("argv is %s\n", argv[2]);
                printf("Are you ready?\n");
                scanf("%s",str);
        }

        int colcount, rowcount, pixel, offsetcnt, begoffsetcnt;
        offsetcnt = 0;


        while ( i < 2 )
        {
                value = getc(fpi);
                offsetcnt++;
                if ( value == 10 )
                        i++;
                if ( value == 0 )
                        return EXIT_FAILURE;
        }

        fscanf(fpi, "%d", &colcount);
        offsetcnt++;
        if ( colcount > 255 ) {
                printf("This file is not compatable.\n");
                return EXIT_FAILURE;
        }

        fscanf(fpi, "%d", &rowcount);
        offsetcnt++;

        fscanf(fpi, "%d", &value);                                      //The max value
        offsetcnt++;

        if ( testing != 0 ) {
                printf("The pixel row height is %d.\n", rowcount);              //The height of the image
                printf("The pixel row height is %d.\n", rowcount);              //The height of the image
                printf("The  old file offset is %d.\n", offsetcnt);
        }

        offsetcnt = 0;
        i = 0;
        fseek (fpi, offsetcnt,SEEK_SET);
        while ( i < 4 )
        {
                value = getc(fpi);
                offsetcnt++;
                if ( value == 10 )
                        i++;
                if ( value == 0 )
                        return EXIT_FAILURE;
        }

        if ( testing != 0 ) {
                printf("The new file offset is %d.\n", offsetcnt);
        }
        begoffsetcnt = offsetcnt;


        int pixelcnt;
        int rowcounter;
        int colcounter;
        int j;
        int k;
        int parsecnt;
        int parsecntr;
        colcounter = (colcount * rowcount);
        parsecntr = 0;
        parsecnt = (colcount - 1 );
        int logicor;
        int finishedbyte;
        FILE *fpo;
        if ( testing ){
                fpo=popen("lp","w");
        } else {
                fpo=stdout;
        }

        //fopen(std"/tmp/output.txt","w");


        putc( 27, fpo );                                                //Send ESC code for printing graphics
        putc( 'U', fpo );
        putc( 1, fpo );
        putc( 27, fpo );                                                //Send ESC code for unidirectional printing
        putc( '3', fpo );
        putc( 0, fpo );





        j = 0;
        while ( j < rowcount )
//      while ( j < 4 )
        {

                putc( 27, fpo );
                putc( 42, fpo );
                putc( 0, fpo );
                putc( colcount, fpo );
                putc( 0, fpo );

                i = 0;
                while ( i < colcount )
//              while ( i < 1 )
                {
                        pixelcnt = 0;
                        logicor = (0x80);
                        finishedbyte = 0;
                        while ( pixelcnt < 8 )
                        {
                                fscanf(fpi, "%d", &pixel);              //Read in the red,blue and green pixel values
                                fscanf(fpi, "%d", &pixel);
                                fscanf(fpi, "%d", &pixel);
                                if (testing != 0 )
                                        printf("The pixel value is %d.", pixel);

                                if (pixel != EOF ) {
                                        if ( pixel > 128 ) {
                                                if (testing != 0 ){
                                                        printf(" This means the pixel is turned off.\n");
                                                }
                                        } else {
                                                if (testing != 0 ){
                                                        printf(" This means the pixel is turned on.\n");
                                                }
                                                finishedbyte = ( finishedbyte + logicor );
                                        }
                                } else {
                                        if (testing != 0 )
                                                printf(" EOF has been reached, pad with off pixels.\n");
                                }

                                pixelcnt++;
                                logicor = ( logicor / 2 );

                                parsecntr = 0;                                          //Parse to the next pixels we need
                                while ( parsecntr < parsecnt )
                                {
                                        fscanf(fpi, "%d", &pixel);
                                        fscanf(fpi, "%d", &pixel);
                                        fscanf(fpi, "%d", &pixel);
                                        if (testing != 0 )
                                                printf("%d of %d = %d.\n", parsecntr, parsecnt, pixel );

                                        parsecntr++;
                                }
                        }
                        putc( finishedbyte , fpo );                                     // Put the finished byte in output file
                        if (testing != 0 )
                                printf("This is the result of the logical or: %d\n", finishedbyte);

                        fseek (fpi, offsetcnt,SEEK_SET);
                        if (testing != 0 )
                                printf("This is the current offset %d.\n", offsetcnt);

                        k = 0;
                        while ( k < 3 )
                        {
                                value = getc(fpi);
                                offsetcnt++;
                                if ( value == 10 )
                                        k++;

                                if (value == EOF )
                                        k = 3;
                        }


                        if (testing != 0 )
                                printf("This is the current offset %d.\n", offsetcnt);

                        fseek (fpi, offsetcnt,SEEK_SET);
                        i++;
                }


                putc( 0x0A, fpo);

                k = 0;
                offsetcnt = begoffsetcnt;
                if (testing != 0 )
                        printf("This is the current offset %d.\n", offsetcnt);

                fseek (fpi, offsetcnt,SEEK_SET);
                while ( k < (colcount * 24) )                   // 24 is obtained by mult the 8 rows by the 3 pixel count.
                {
                        value = getc(fpi);
                        offsetcnt++;
                        if ( value == 10 )
                                k++;

                        if (value == EOF )
                                k = (colcount * 24);
                }
                if (value != EOF ) {
                        if (testing != 0 )
                                printf("This is the current offset %d.\n", offsetcnt);

                        begoffsetcnt = offsetcnt;
                        fseek (fpi, offsetcnt,SEEK_SET);
                        j = j + 8;
                }

                else    {
                        if (testing != 0 )
                                printf("EOF encountered\n");

                        j = rowcount;
                }

        }

        putc( 0x0D, fpo);
        putc( 0x0A, fpo);

        if (testing != 0 ) {
                putc('T', fpo);
                putc('h', fpo);
                putc('e', fpo);
                putc(' ', fpo);
                putc('e', fpo);
                putc('n', fpo);
                putc('d', fpo);
                putc('.', fpo);
                putc( 0x0D, fpo);
                putc( 0x0A, fpo);
                putc( 0x0A, fpo);                                       //Put some extra line feeds in
                putc( 0x0A, fpo);
                putc( 0x0A, fpo);
                putc( 0x0A, fpo);

                putc( 27, fpo);
                putc( 'J', fpo);
                putc( 255, fpo);

                putc( 0x1B, fpo );                                      //This cuts the paper
                putc( 'm', fpo );

        }

        putc( 27, fpo);                                                 //Return the printer back to original settings
        putc( '@', fpo);

        fflush( fpo );

        if ( testing ){
                pclose( fpo );
        } else {
                fclose(fpo);
        }

        fclose(fpi);

        printf("Process complete!\n");

        return EXIT_SUCCESS;
}
