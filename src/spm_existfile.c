/*
 * $Id: spm_existfile.c 1800 2008-06-09 18:56:42Z guillaume $
 * Guillaume Flandin
 */

#include "mex.h"

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    bool status    = false;
    char *filename = NULL;
    FILE *fid      = NULL;
    
    if (nrhs != 1)
        mexErrMsgTxt("One input only required.");
    else
    {
        if (!mxIsChar(prhs[0]))
            mexErrMsgTxt("Input must be a string.");
        filename = mxArrayToString(prhs[0]);
        fid = fopen(filename,"r");
        if (fid != NULL)
        {
            status = true;
            fclose(fid);
        }
        mxFree(filename);
    }
        
    plhs[0] = mxCreateLogicalScalar(status);
}
