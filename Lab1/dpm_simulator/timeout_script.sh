#!/bin/bash

$(make)

#Handle user input.
if [[ "${1}" == "-dst" ]]; then
	if [[ -f "./example/${2}.txt" ]]; then
		dst="${2}"
	else
		echo "${2} cannot open file ./example/${2}.txt"
		exit
	fi
elif [[ "${1}" == "-h" ]]; then
	echo "-dst : <dstName> , specify distribution name. The relative path ./example/ will be applied to <dstName>. The .txt estention must not be specified." 
	echo "Ex. to identify ./example/wl.txt command is -dst wl"
	exit
else
	echo "No distribution specified, type -h for help"
	exit
fi

# Declare timeout, idle and sleep, bounds. 
min_tm_idle=5
max_tm_idle=400
min_tm_sleep=5
max_tm_sleep=400
step_tm=5

#CSV variables.
outCsv_tis="${dst}_dpm_report_idle_sleep.csv"
outCsv_t="${dst}_dpm_report_idle.csv"

total_test=$(( ((${max_tm_idle} - ${min_tm_idle} + 1)/${step_tm})*((${max_tm_sleep} - ${min_tm_sleep} + 1)/${step_tm})  ))

#Initialize CSVs, if using matlab these two lines must be deleted.
#Two different CSV will be printed for the two policies considering only idle, and both idle and sleep.
echo "Parameters => idle_timeout: [${min_tm_idle}, ${max_tm_idle}]; step: ${step_tm}" >> ${outCsv_t}
echo "distribution;timeoutIdle;energySaved" >> ${outCsv_t}

echo "Parameters => idle_timeout: [${min_tm_idle}, ${max_tm_idle}]; sleep_timeout: [${min_tm_sleep}; ${max_tm_sleep}]; step: ${step_tm}" >> ${outCsv_tis}
echo "distribution;timeoutIdle;timeoutSleep;energySaved" >> ${outCsv_tis}

#Print simulation sweep parameters and distribution.
echo ""
echo "-------------------Simulation parameters--------------------"
echo ""
echo "[Distribution]  ./example/${dst}.txt"
echo "[Timeout idle]  start: ${min_tm_idle}  stop: ${max_tm_idle}"
echo "[Timeout sleep] start: ${min_tm_sleep}  stop: ${max_tm_sleep}"
echo "[Step]          ${step_tm}"
echo ""
echo "------------------------------------------------------------"
echo ""
echo "----------------------Start simulation----------------------"
echo ""

c_test=0
flag=( 1 1 1 1 1 1 1 1 1 1 )

#Start algorithm.
for ((i = $min_tm_idle ; i <= $max_tm_idle ; i += step_tm)); do

	#Execute simulator without sleep state (-t).
	dpm_out_t=$(./dpm_simulator -t $i -psm ./example/psm.txt -wl ./example/${dst}.txt)
	#Transform string into an array.
	array_dpm_out_t=($dpm_out_t)
	#Power saving values is [166].
	#Append row to idle csv.
	echo "${dst};$i;${array_dpm_out_t[166]}" >> ${outCsv_t}

	for ((j = $min_tm_sleep ; j <= $max_tm_sleep ; j += step_tm)); do
		#Compute and display percantage.
		c_test=$(( ${c_test} + 1 ))
		percentage=$(( (c_test*100)/total_test ))

		if [[ $percentage -eq 10 ]] && [[ ${flag[0]} -eq 1 ]]
		then
			echo "[Computation] 10%"
			flag[0]=0
		elif [[ $percentage -eq 20 ]] && [[ ${flag[1]} -eq 1 ]]
		then
			echo "[Computation] 20%"
			flag[1]=0
		elif [[ $percentage -eq 30 ]] && [[ ${flag[2]} -eq 1 ]]
		then
			echo "[Computation] 30%"
			flag[2]=0
		elif [[ $percentage -eq 40 ]] && [[ ${flag[3]} -eq 1 ]]
		then
			echo "[Computation] 40%"
			flag[3]=0
		elif [[ $percentage -eq 50 ]] && [[ ${flag[4]} -eq 1 ]]
		then
			echo "[Computation] 50%"
			flag[4]=0
		elif [[ $percentage -eq 60 ]] && [[ ${flag[5]} -eq 1 ]]
		then
			echo "[Computation] 60%"
			flag[5]=0
		elif [[ $percentage -eq 70 ]] && [[ ${flag[6]} -eq 1 ]]
		then
			echo "[Computation] 70%"
			flag[6]=0
		elif [[ $percentage -eq 80 ]] && [[ ${flag[7]} -eq 1 ]]
		then
			echo "[Computation] 80%"
			flag[7]=0
		elif [[ $percentage -eq 90 ]] && [[ ${flag[8]} -eq 1 ]]
		then
			echo "[Computation] 90%"
			flag[8]=0
		elif [[ $percentage -eq 100 ]] && [[ ${flag[9]} -eq 1 ]]
		then
			echo "[Computation] 100%"
			flag[9]=0
		fi

		#Execute simulator with both sleep and idle states (-tis).
		dpm_out_tis=$(./dpm_simulator -tis $i $j -psm ./example/psm.txt -wl ./example/${dst}.txt)
		
		#Transform string into an array.
		array_dpm_out=($dpm_out_tis)
		#Power saving values is [166].
		#Append row to idle and sleep csv.
		echo "${dst};$i;$j;${array_dpm_out[166]}" >> ${outCsv_tis}
	done
done
echo ""
echo "[end] 		  Simulation results written in ${outCsv_t} and ${outCsv_tis}"


