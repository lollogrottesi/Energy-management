#include "inc/psm.h"

int psm_read(psm_t *p, char *filename)
{

    int i, j;
	FILE *fp;
	fp = fopen(filename, "r");
	if(fp == NULL) {
		printf("error: can't open file %s!\n", filename);
		return 0;
	}

	//read the power for each state
	for(i = 0; i < PSM_N_STATES; i++)
	{
		if(fscanf(fp, "%lf", &p->power[i]) != 1) {
			printf("error reading file %s!\n", filename);
			fclose(fp);
			return 0;;
		}
	}

	//read the transition costs
	for(i = 0; i < PSM_N_STATES; i++) {
        for(j = 0; j < PSM_N_STATES; j++) {
            if(fscanf(fp, "%lf/%lf", &p->tran_energy[i][j],
                        &p->tran_time[i][j]) != 2) {
                printf("error reading file %s!\n", filename);
                fclose(fp);
                return 0;
            }
        }
    }
	fclose(fp);
    return 1;
}

void psm_print(psm_t p)
{
    int i, j;
	for(i = 0; i < PSM_N_STATES; i++){
		printf("[psm] State %s: power = %.2fmW\n",
                PSM_STATE_NAME(i), p.power[i]);
    }

    for(i = 0; i < PSM_N_STATES; i++) {
        for(j = 0; j < PSM_N_STATES; j++) {
			if(i != j && psm_tran_allowed(p, i, j)) {
				printf("[psm] %s -> %s transition: energy  = %.0fuJ, time = %.0fus\n",
						PSM_STATE_NAME(i), PSM_STATE_NAME(j),
						psm_tran_energy(p, i, j), psm_tran_time(p, i, j));
			}
        }
    }
    printf("\n");
}

psm_time_t psm_break_even_time(psm_t psm, psm_state_t next)
{
	//psm_state_t  curr      = PSM_STATE_ACTIVE;
	psm_time_t   tr_time   = psm_tran_time (psm, PSM_STATE_ACTIVE, next)  + psm_tran_time(psm, next, PSM_STATE_ACTIVE);
	psm_energy_t tr_energy = psm_tran_energy(psm, PSM_STATE_ACTIVE, next) + psm_tran_energy(psm, next, PSM_STATE_ACTIVE);
	psm_power_t tr_power =  tr_energy / tr_time;
	tr_power = tr_power*1000; //Energy in uj time in us so power is w. notation is in mw so multiply for 1000.
	//printf("%f\n", tr_power);
	psm_time_t Tbe;
	if (tr_power <= psm.power[PSM_STATE_ACTIVE]){
		//Case Ptr <= Pon.
		Tbe = tr_time;
	} else {
		//Case Ptr > Pon.
		Tbe = tr_time + tr_time*((tr_power - psm.power[PSM_STATE_ACTIVE])/(psm.power[PSM_STATE_ACTIVE] - psm.power[next]));
	}

	return Tbe;
}

int psm_tran_allowed(psm_t psm, psm_state_t curr, psm_state_t next)
{
    return psm.tran_energy[curr][next] != -1;
}

psm_energy_t psm_tran_energy(psm_t psm, psm_state_t curr, psm_state_t next)
{
    return psm.tran_energy[curr][next];
}

psm_time_t psm_tran_time(psm_t psm, psm_state_t curr, psm_state_t next)
{
    return psm.tran_time[curr][next];
}

psm_energy_t psm_state_energy(psm_t psm, psm_state_t curr)
{
    return psm.power[curr] * (PSM_POWER_UNIT * PSM_TIME_UNIT) / PSM_ENERGY_UNIT;
}

psm_time_t psm_duration(psm_interval_t i)
{
	return i.end - i.start;
}
