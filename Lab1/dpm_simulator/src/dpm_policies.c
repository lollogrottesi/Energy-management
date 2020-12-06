#include "inc/dpm_policies.h"
#include <math.h>
//double pow(double x, double y)
int dpm_simulate(psm_t psm, dpm_policy_t sel_policy, dpm_timeout_params
		tparams, dpm_history_params hparams, char* fwl)
{

	FILE *fp;
	psm_interval_t idle_period;
	psm_interval_t history[DPM_HIST_WIND_SIZE];
	psm_time_t curr_time = 0;
	psm_state_t curr_state = PSM_STATE_ACTIVE;
    psm_state_t prev_state = PSM_STATE_ACTIVE;
    psm_energy_t e_total = 0;
    psm_energy_t e_tran;
    psm_energy_t e_tran_total = 0;
    psm_energy_t e_total_no_dpm = 0;
    psm_time_t t_tran_total = 0;
    psm_time_t t_waiting = 0;
	psm_time_t t_idle_ideal = 0;
    psm_time_t t_state[PSM_N_STATES] = {0};
    /*psm_time_t Tbe_idle;
    psm_time_t Tbe_sleep;*/
    int n_tran_total = 0;
    psm_time_t last_active;
	fp = fopen(fwl, "r");
	if(!fp) {
		printf("[error] can't open file %s!\n", fwl);
		return 0;
	}

	dpm_init_history(history);
	
	hparams.threshold[0] = psm_break_even_time(psm, PSM_STATE_IDLE);
	hparams.threshold[1] = psm_break_even_time(psm, PSM_STATE_SLEEP);
    // main loop
    while(fscanf(fp, "%lf%lf", &idle_period.start, &idle_period.end) == 2) {

        t_idle_ideal += psm_duration(idle_period);
		last_active  = dpm_update_history(history, idle_period);
        //History based check.
        //psm_time_t pred_Idle = hparams.alpha[0] + hparams.alpha[1]*psm_duration(history[DPM_HIST_WIND_SIZE-2]) + hparams.alpha[2]*last_active + hparams.alpha[3]*psm_duration(history[DPM_HIST_WIND_SIZE-2])*last_active + hparams.alpha[4]*psm_duration(history[DPM_HIST_WIND_SIZE-2])*pow(last_active, 2) + hparams.alpha[5]*pow(psm_duration(history[DPM_HIST_WIND_SIZE-2]), 2)*last_active + hparams.alpha[6]*pow(psm_duration(history[DPM_HIST_WIND_SIZE-2]), 2) + hparams.alpha[7]*pow(last_active, 2);  
        //printf("Predicted idle time is: %f and real idle is: %f\n", pred_Idle, psm_duration(idle_period));
        
        /*printf("idle: %lf %lf\n", idle_period.start, idle_period.end);*/
        //psm_time_t pred_Idle = hparams.alpha[0] + hparams.alpha[1]*psm_duration(history[DPM_HIST_WIND_SIZE-2]) + hparams.alpha[2]*last_active + hparams.alpha[3]*psm_duration(history[DPM_HIST_WIND_SIZE-2])*last_active + hparams.alpha[4]*psm_duration(history[DPM_HIST_WIND_SIZE-2])*pow(last_active, 2) + hparams.alpha[5]*pow(psm_duration(history[DPM_HIST_WIND_SIZE-2]), 2)*last_active + hparams.alpha[6]*pow(psm_duration(history[DPM_HIST_WIND_SIZE-2]), 2) + hparams.alpha[7]*pow(last_active, 2);  
        //printf("Predicted idle time is: %f and real idle is: %f\n", pred_Idle, psm_duration(idle_period));
        
        // for each instant until the end of the current idle period
		for (; curr_time < idle_period.end; curr_time++) {

            // compute next state
            if(!dpm_decide_state(&curr_state, curr_time, idle_period, history,
                        sel_policy, tparams, hparams, last_active)) {
                printf("[error] cannot decide next state!\n");
                return 0;
            }
            /*printf("curr: %lf, state: %s\n", curr_time, PSM_STATE_NAME(curr_state));*/

            if (curr_state != prev_state) {
                if(!psm_tran_allowed(psm, prev_state, curr_state)) {
                    printf("[error] prohibited transition!\n");
                    return 0;
                }
                e_tran = psm_tran_energy(psm, prev_state, curr_state);
                e_tran_total += e_tran;
                t_tran_total += psm_tran_time(psm, prev_state, curr_state);
                n_tran_total++;
                e_total += psm_state_energy(psm, curr_state) + e_tran;
            } else {
                e_total += psm_state_energy(psm, curr_state);
            }
            e_total_no_dpm += psm_state_energy(psm, PSM_STATE_ACTIVE);
            // statistics of time units spent in each state
            t_state[curr_state]++;
            // time spent actively waiting for timeout expirations
            if(curr_state == PSM_STATE_ACTIVE && curr_time >=
                    idle_period.start) {
                t_waiting++;
            }

            prev_state = curr_state;
        }
    }
    fclose(fp);

    printf("[sim] Active time in profile = %.6lfs \n", (curr_time - t_idle_ideal) * PSM_TIME_UNIT);
    printf("[sim] Idle time in profile = %.6lfs\n", t_idle_ideal * PSM_TIME_UNIT);
    printf("[sim] Total time = %.6lfs\n", curr_time * PSM_TIME_UNIT);
    printf("[sim] Timeout waiting time = %.6lfs\n", t_waiting * PSM_TIME_UNIT);
    for(int i = 0; i < PSM_N_STATES; i++) {
        printf("[sim] Total time in state %s = %.6lfs\n", PSM_STATE_NAME(i),
                t_state[i] * PSM_TIME_UNIT);
    }
    printf("[sim] Time overhead for transition = %.6lf s\n",t_tran_total * PSM_TIME_UNIT);
    printf("[sim] N. of transitions = %d\n", n_tran_total);
    printf("[sim] Energy for transitions = %.6f J\n", e_tran_total * PSM_ENERGY_UNIT);
    printf("[sim] Energy w/o DPM = %.6fJ, Energy w DPM = %.6fJ\n",
            e_total_no_dpm * PSM_ENERGY_UNIT, e_total * PSM_ENERGY_UNIT);
    printf("[sim] %2.1f percent of energy saved.\n", 100*(e_total_no_dpm - e_total) /
            e_total_no_dpm);
    printf("Tbe for idle : %f\n", hparams.threshold[0]);
	printf("Tbe for sleep: %f\n", hparams.threshold[1]);
	return 1;
}

int dpm_decide_state(psm_state_t *next_state, psm_time_t curr_time,
        psm_interval_t idle_period, psm_interval_t *history, dpm_policy_t policy,
        dpm_timeout_params tparams, dpm_history_params hparams, psm_time_t last_active)
{
    switch (policy) {

        case DPM_TIMEOUT:
        	if (tparams.timeout[1] == TIMEOUT_NOT_DEFINED) { //Case only one timeout defined.
	            if(curr_time > idle_period.start + tparams.timeout[0]) {
	                *next_state = PSM_STATE_IDLE;
	            } else {
	                *next_state = PSM_STATE_ACTIVE;
	            }
	        }//End timeout idle.
	        else {
	        	if(curr_time > idle_period.start + tparams.timeout[0] && curr_time < idle_period.start + tparams.timeout[0] + tparams.timeout[1]) {
	                *next_state = PSM_STATE_IDLE;
	            } else if(curr_time > idle_period.start + tparams.timeout[0] + tparams.timeout[1]) {
	            	*next_state = PSM_STATE_SLEEP;
	            } else {
	                *next_state = PSM_STATE_ACTIVE;
	            }
	        }//End timeout idle and sleep.
            /* LAB 2 EDIT */
            break;

        case DPM_HISTORY:
            if(curr_time < idle_period.start) {
                *next_state = PSM_STATE_ACTIVE;
            } else {
                //history[DPM_HIST_WIND_SIZE-2] contains the INTERVAL T_idle [i-1].
                //printf ("T_idle [i-1] = %f , T_active[i] = %f\n", psm_duration(history[3]), last_active);
                psm_time_t pred_Idle = hparams.alpha[0] + hparams.alpha[1]*psm_duration(history[DPM_HIST_WIND_SIZE-2]) + hparams.alpha[2]*last_active + hparams.alpha[3]*psm_duration(history[DPM_HIST_WIND_SIZE-2])*last_active + hparams.alpha[4]*psm_duration(history[DPM_HIST_WIND_SIZE-2])*pow(last_active, 2) + hparams.alpha[5]*pow(psm_duration(history[DPM_HIST_WIND_SIZE-2]), 2)*last_active + hparams.alpha[6]*pow(psm_duration(history[DPM_HIST_WIND_SIZE-2]), 2) + hparams.alpha[7]*pow(last_active, 2);  
                //printf("Predicted idle time is: %f and real idle is: %f\n", pred_Idle, psm_duration(idle_period));
                if (pred_Idle > hparams.threshold[1]) { // case pred_idle > Tbe_sleep
                	*next_state = PSM_STATE_SLEEP;
                } else if(pred_Idle > hparams.threshold[0]) { // case pred_idle > Tbe_idle
                	*next_state = PSM_STATE_IDLE;
                } else {
                	*next_state = PSM_STATE_ACTIVE; // case pred_idle < Tbe_idle and Tbe_sleep.
                }
            }
            break;

        default:
            printf("[error] unsupported policy\n");
            return 0;
    }
	return 1;
}

/* initialize idle time history */
void dpm_init_history(psm_interval_t *h)
{
	psm_interval_t interval_init;
	interval_init.start = 0;
	interval_init.end  = 0; 
	for (int i=0; i<DPM_HIST_WIND_SIZE; i++) {
		h[i] = interval_init;
	}
}

/* update idle time history */
double dpm_update_history(psm_interval_t *h, psm_interval_t idle_period)
{
	for (int i=0; i<DPM_HIST_WIND_SIZE-1; i++){
		h[i] = h[i+1];
	}
	h[DPM_HIST_WIND_SIZE-1] = idle_period;
    //printf("Current idle is %f, previous is %f\n", psm_duration(idle_period), psm_duration(h[DPM_HIST_WIND_SIZE-2]));
    //printf("Current active time: %f\n", (idle_period.start - h[DPM_HIST_WIND_SIZE-2].end));
	return idle_period.start - h[DPM_HIST_WIND_SIZE-2].end;
}
