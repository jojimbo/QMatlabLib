
//    X = STR2DOUBLEQ(S) converts the string S, which should be an
//    ASCII character representation of a real value, to MATLAB's double
//    representation.  The string may contain digits,a decimal point, 
//    a leading + or - sign and 'e' preceding a power of 10 scale factor
// 
//    X = STR2DOUBLEQ(C) converts the strings in the cell array of strings C
//    to double.  The matrix X returned will be the same size as C.  NaN will
//    be returned for any cell which is not a string representing a valid
//    scalar value. NaN will be returned for individual cells in C which are
//    cell arrays.
    
//    Examples
//       str2doubleq('123.45e7')
//       str2doubleq('3.14159')
//       str2doubleq({'2.71' '3.1415'})
//       str2doubleq({'2.71' '3.1415'; 'abc','123.45e7'})
     
// NOTE ABOUT ATOF:
// To get ultimate performance c-function atof has most optimal performance
// Just a word of caution: atof behaves differently in cases when s 
// cannot be interpreted as string in the same sense as Matlabs str2double does
// For example input "2.2a" produces a double number 2.2. 
// When you know your input always resembeles true number value, it is "safe" to use atof. 
// This is the case for example when you use regexp to capture tokens that are always 
// by construction in numeric form, e.g (\d+)

#include "mex.h"
#include<string>
#include<sstream>

double string_to_double( const char *s )
{
    // If you uncomment this, make the rest of the code in this function 
    // block commented. Please read the note above about atof usage.
    // return atof(s);
	
    static std::istringstream iss;
    iss.clear(); 
    iss.str(s);
    double x;
    iss >> x;
    if(!(iss && (iss >> std::ws).eof()))
    {
        return mxGetNaN();
    }
    return x;
} 

void mexFunction( int nlhs, mxArray *plhs[], 
		  int nrhs, const mxArray*prhs[] )

{
	double *writePtr;
	char *strPtr;
    
    if ( nrhs == 0 )
	{
		mexErrMsgTxt("Too few input arguments"); 
	}
    else if  ( nrhs >= 2 )
    {
        mexErrMsgTxt("Too many input arguments."); 
    }   
	if ( mxIsChar(prhs[0]) )
	{
		// branch to handle chars
		// get pointer to the beginning of the char
		strPtr = mxArrayToString(prhs[0]);
        // allocate memory to output
		plhs[0] = mxCreateDoubleMatrix(1,1, mxREAL);
        // set pointer to beginning of the memory
		writePtr = mxGetPr(plhs[0]);
        
        *(writePtr) = string_to_double(strPtr);
        mxFree(strPtr);
	}
	else if ( mxIsCell(prhs[0]) )
	{
		
		mwSize mrows,ncols,i;
		mrows = mxGetM( prhs[0] );
		ncols = mxGetN( prhs[0] );
        // allocate memory to results
        plhs[0] = mxCreateDoubleMatrix(mrows,ncols, mxREAL);
 		
		writePtr = mxGetPr(plhs[0]);
		// get pointer to the beginning of array
        
		for (i = 0; i < mrows*ncols; i++) 
 		{
			mxArray *Context = mxGetCell(prhs[0],i);
            if ( Context == 0  || !mxIsChar(Context) )
			{
				*(writePtr+i) = mxGetNaN();
			}
			else
			{
				char *strPtr = mxArrayToString(Context);
				if (strPtr != 0)
                {
                    *(writePtr+i) = string_to_double(strPtr);
                }
                else
                {
                    *(writePtr+i) = mxGetNaN();
                }
                mxFree(strPtr);
			}
		}
	}
    else if ( mxIsDouble(prhs[0]) )
    {
        // return vector of NaN's
        mwSize mrows,ncols,i;
		mrows = mxGetM( prhs[0] );
		ncols = mxGetN( prhs[0] );
        if (mrows == 0 && ncols == 0)
        {
            // Case where input is empty array must return NaN value
            mrows = 1; ncols = 1;
        }
        plhs[0] = mxCreateDoubleMatrix(mrows,ncols, mxREAL);
        writePtr = mxGetPr(plhs[0]);
        for (i = 0; i < mrows*ncols; i++) 
        {
            *(writePtr+i) = mxGetNaN();
        }
    }
    else
	{
		// case to handle other situations, eg input is a class etc....
        // allocate memory to output
		plhs[0] = mxCreateDoubleMatrix(1,1, mxREAL);
		// get pointer to the beginning of the allocated memory
		writePtr = mxGetPr(plhs[0]);
		// write NaN to the first element of it
        writePtr[0] = mxGetNaN();
	}
};

