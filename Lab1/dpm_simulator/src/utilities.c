#include "inc/utilities.h"

int parse_args(int argc, char *argv[], char *fwl, psm_t *psm, dpm_policy_t
        *selected_policy, dpm_timeout_params *tparams, dpm_history_params
        *hparams)
{
    int cur = 1;
    while(cur < argc) {
        if(strcmp(argv[cur], "-help") == 0) {
            print_command_line();
            return 0;
        }

        // set policy to timeout and get timeout value
        if(strcmp(argv[cur], "-t") == 0) {
            *selected_policy = DPM_TIMEOUT;
            if(argc > cur + 1) {
                tparams->timeout[0] = atof(argv[++cur]);
                tparams->timeout[1] = TIMEOUT_NOT_DEFINED;
            }
            else return	0;
        }

        // set policy to timeout and get timeout value for idle and sleep
        if(strcmp(argv[cur], "-tis") == 0) {
            *selected_policy = DPM_TIMEOUT;
            if(argc > cur + 2) {
                tparams->timeout[0] = atof(argv[++cur]);
                tparams->timeout[1] = atof(argv[++cur]);
            }
            else return 0;
        }

        // set policy to history based and get parameters and thresholds
        if(strcmp(argv[cur], "-h") == 0) {
            *selected_policy = DPM_HISTORY;
            if(argc > cur + DPM_HIST_WIND_SIZE){
                int i;
                for(i = 0; i < DPM_HIST_WIND_SIZE; i++) {
                    hparams->alpha[i] = atof(argv[++cur]);
                    //printf("Alpha %d :%f\n", i, hparams->alpha[i]);
                }
                /*hparams->threshold[0] = atof(argv[++cur]);
                hparams->threshold[1] = atof(argv[++cur]);*/
            } else return 0;
        }

        // set name of file for the power state machine
        if(strcmp(argv[cur], "-psm") == 0) {
            if(argc <= cur + 1 || !psm_read(psm, argv[++cur]))
                return 0;
        }

        // set name of file for the workload
        if(strcmp(argv[cur], "-wl") == 0)
        {
            if(argc > cur + 1)
            {
                strcpy(fwl, argv[++cur]);
            }
            else return	0;
        }
        cur ++;
    }
    return 1;
}

void print_command_line(){
	printf("\n******************************************************************************\n");
	printf(" DPM simulator: \n");
	printf("\t-t  <timeout>: timeout of the timeout policy considerig only idle state\n");
    printf("\t-tis <timeout1> <timeout1>: timeout policy considering both idle and sleep state\n");
	printf("\t-h <Value0>.....Value7>: history-based policy thresholds are computed internally using Tbe\n");
	printf("\t   <Value0-7> value of coefficients\n");
	printf("\t-psm <psm filename>: the power state machine file\n");
	printf("\t-wl <wl filename>: the workload file\n");
	printf("******************************************************************************\n\n");
}
