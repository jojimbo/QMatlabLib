#include "mex.h"
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    // lhs are outputs
    // rhs are inputs
    //double *rows_start, *rows_end, *cols_start, *cols_end;
    double *in, *out;
    mwIndex i,j;
    mwSize numRows;
    mwSize newNRows, newNCols;
    int rows_start, rows_end, cols_start, cols_end;

    /* input checks */
    if (nrhs != 5) {
        mexErrMsgIdAndTxt("MATLAB:nargchk", "Wrong number of arguments.");
    }
    if (mxGetNumberOfDimensions(prhs[0])>2 || !mxIsDouble(prhs[0])) {
        mexErrMsgIdAndTxt("MATLAB:wrongDims", "Expecting 2D double matrix.");
    }
    if (mxGetM(prhs[0])<100 || mxGetN(prhs[0])<100) {
        mexErrMsgIdAndTxt("MATLAB:wrongDims", "Matrix size must be >= 100x100.");
    }
    
    /* extract number of elements to extract */
    rows_start  = mxGetScalar(prhs[1]);
    rows_end    = mxGetScalar(prhs[2]); //rows_end    = mxGetPr(prhs[2]);
    cols_start  = mxGetScalar(prhs[3]);
    cols_end    = mxGetScalar(prhs[4]);
    
    newNRows = rows_end - rows_start;
    newNCols = cols_end - cols_start;
    
    /* extract sub-matrix */
    plhs[0] = mxCreateDoubleMatrix(newNRows, newNCols, mxREAL);
    out = mxGetPr(plhs[0]); // mxGetPr: Real data elements in array of type DOUBLE
    
    in = mxGetPr(prhs[0]);
    numRows = mxGetM(prhs[0]);
    for(j=0; j<newNRows; j++) {
        for(i=0; i<newNCols; i++) {
            *out++ = in[i + (numRows)*j];
        }
    }
}