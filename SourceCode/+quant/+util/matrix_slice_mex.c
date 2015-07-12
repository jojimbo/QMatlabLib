#include "mex.h"
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    // lhs are outputs
    // rhs are inputs
    // int rows_start, rows_end, cols_start, cols_end;
    double *in, *out;
    mwIndex i,j;
    mwSize numRows;

    /* input checks */
    if (nrhs != 1 || nlhs > 1) {
        mexErrMsgIdAndTxt("MATLAB:nargchk", "Wrong number of arguments.");
    }
    if (mxGetNumberOfDimensions(prhs[0])>2 || !mxIsDouble(prhs[0])) {
        mexErrMsgIdAndTxt("MATLAB:wrongDims", "Expecting 2D double matrix.");
    }
    if (mxGetM(prhs[0])<100 || mxGetN(prhs[0])<100) {
        mexErrMsgIdAndTxt("MATLAB:wrongDims", "Matrix size must be >= 100x100.");
    }
    
    /* extract number of elements to extract */
    //rows_start  = (int)*mxGetPr(prhs[1]);
    //rows_end    = (int)*mxGetPr(prhs[2]);
    //cols_start  = (int)*mxGetPr(prhs[3]);
    //cols_end    = (int)*mxGetPr(prhs[4]);
    
    /* extract sub-matrix */
    plhs[0] = mxCreateDoubleMatrix(100, 100, mxREAL);
    out = mxGetPr(plhs[0]); // mxGetPr: Real data elements in array of type DOUBLE
    
    in = mxGetPr(prhs[0]);
    numRows = mxGetM(prhs[0]);
    for(j=0; j<100; j++) {
        for(i=0; i<100; i++) {
            *out++ = in[i + numRows*j];
        }
    }
}