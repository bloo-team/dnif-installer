#!/bin/bash


#-------------------------------------------------Reading inputs-------------------------------------------------------

echo -e "\n* Select the DNIF component you would like to check Prerequisites for:" | tee -a /var/tmp/prechecks.log
echo -e "    [1] Core (CO)" | tee -a /var/tmp/prechecks.log
echo -e "    [2] Local Console (LC)" | tee -a /var/tmp/prechecks.log
echo -e "    [3] Datanode (DN)" | tee -a /var/tmp/prechecks.log
echo -e "    [4] Adapter (AD)" | tee -a /var/tmp/prechecks.log
echo -e "    [5] Pico\n" | tee -a /var/tmp/prechecks.log

COMPONENT=""
while [[ ! $COMPONENT =~ ^[1-5] ]]; do
	echo -e "Pick the number corresponding to the component (1 - 5):  \c" | tee -a /var/tmp/prechecks.log
        read -r COMPONENT
done

echo -e $COMPONENT >> /var/tmp/prechecks.log

echo -e "\n* Select the Deployment Environment:" | tee -a /var/tmp/prechecks.log
echo -e "    [1] Test Environment" | tee -a /var/tmp/prechecks.log
echo -e "    [2] Production Environment\n" | tee -a /var/tmp/prechecks.log

ENVIR=""
while [[ ! $ENVIR =~ ^[1-2] ]]; do
	echo -e "Pick the number corresponding to the Environemt (1 - 2):  \c" | tee -a /var/tmp/prechecks.log
    read -r ENVIR
done

echo -e $ENVIR >> /var/tmp/prechecks.log

echo -e "\n-----------------------------------Enter Customer Name----------------------------" | tee -a /var/tmp/prechecks.log
echo -e "Enter the Customer Name :  \c" | tee -a /var/tmp/prechecks.log
read -r cust_name

echo -e $cust_name >> /var/tmp/prechecks.log

#----------------------------------------------------Functions----------------------------------------------------------

echo -e "----------------------------------------------------------------------------------\n" | tee -a /var/tmp/prechecks.log
server_hostname=$(hostname)
echo -e "Server Hostname : $server_hostname"  | tee -a /var/tmp/prechecks.log

echo -e "----------------------------------------------------------------------------------\n" | tee -a /var/tmp/prechecks.log
if [ -f /etc/os-release ]; then
    . /etc/os-release
    echo -e "OS: $NAME" | tee -a /var/tmp/prechecks.log
    echo -e "Version: $VERSION" | tee -a /var/tmp/prechecks.log
else
    echo "\n/etc/os-release not found. Cannot detect OS."
fi

# ip_connectivity() function is for testing the connectivty using ping command
ip_connectivity() {

	if [ ! -f /var/tmp/components.txt ]; then
		echo -e "\nComponent files not found. Proceeding to create a new file:\n" | tee -a /var/tmp/prechecks.log
		echo -e "component\tserver ip\thostname" > /var/tmp/components.txt
		CO_HOSTNAME=""
		while [[ -z "$CO_HOSTNAME" || ! "$CO_HOSTNAME" =~ ^[a-zA-Z0-9._-]+$ ]]; do
			echo -e "ENTER CORE HOSTNAME: \c"
			read -r CO_HOSTNAME
		done
		COREIP=""
		while [[ ! $COREIP =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; do
			echo -e "ENTER CORE IP: \c"
			read -r COREIP
		done
		echo -e "core\t$COREIP\t$CO_HOSTNAME" >> /var/tmp/components.txt

		if [ "$COMPONENT" != "5" ]; then
			LC_HOSTNAME=""
			while [[ -z "$LC_HOSTNAME" || ! "$LC_HOSTNAME" =~ ^[a-zA-Z0-9._-]+$ ]]; do
				echo -e "\nENTER CONSOLE HOSTNAME: \c"
				read -r LC_HOSTNAME
			done
			LCIP=""
			while [[ ! $LCIP =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; do
				echo -e "ENTER CONSOLE IP: \c"
				read -r LCIP
			done
			echo -e "console\t$LCIP\t$LC_HOSTNAME" >> /var/tmp/components.txt

			echo ""
			read -p "Enter the number of Datanode servers in your environment: " SERVER_COUNT

			# Check if the input is a valid number
			while ! [[ "$SERVER_COUNT" =~ ^[0-9]+$ && "$SERVER_COUNT" -gt 0 ]]; do
				echo "Please enter a valid positive number."
				read -p "Enter the number of servers in your environment: " SERVER_COUNT
			done

			declare -A SERVER_HOSTNAMES
			declare -A SERVER_IPS

			for (( i=1; i<=SERVER_COUNT; i++ )); do
				echo "----- Server #$i -----"

				# Read hostname
				HOSTNAME=''
				while [[ -z "$HOSTNAME" || ! "$HOSTNAME" =~ ^[a-zA-Z0-9._-]+$ ]]; do
					read -p "Enter hostname for server #$i: " HOSTNAME
				done
				SERVER_HOSTNAMES[$i]=$HOSTNAME
				
				# Read and validate IP
				SERVER_IP=""
				while [[ ! $SERVER_IP =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; do
					read -p "Enter IP address for server #$i: " SERVER_IP
					if [[ ! $SERVER_IP =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
						echo "Invalid IP format. Please enter a valid IP."
					fi
				done
				SERVER_IPS[$i]=$SERVER_IP
			done

			for (( i=1; i<=SERVER_COUNT; i++ )); do
				echo -e "datanode\t${SERVER_IPS[$i]}\t${SERVER_HOSTNAMES[$i]}" >> /var/tmp/components.txt
			done
		fi

		echo ""
		read -p "Enter the number of Adapter servers in your environment: " SERVER_COUNT

		# Check if the input is a valid number
		while ! [[ "$SERVER_COUNT" =~ ^[0-9]+$ && "$SERVER_COUNT" -gt 0 ]]; do
			echo "Please enter a valid positive number."
			read -p "Enter the number of servers in your environment: " SERVER_COUNT
		done

		declare -A SERVER_HOSTNAMES
		declare -A SERVER_IPS

		for (( i=1; i<=SERVER_COUNT; i++ )); do
			echo "----- Server #$i -----"

			# Read hostname
			HOSTNAME=''
			while [[ -z "$HOSTNAME" || ! "$HOSTNAME" =~ ^[a-zA-Z0-9._-]+$ ]]; do
				read -p "Enter hostname for server #$i: " HOSTNAME
			done
			SERVER_HOSTNAMES[$i]=$HOSTNAME

			# Read and validate IP
			SERVER_IP=""
			while [[ ! $SERVER_IP =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; do
				read -p "Enter IP address for server #$i: " SERVER_IP
				if [[ ! $SERVER_IP =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
					echo "Invalid IP format. Please enter a valid IP."
				fi
			done
			SERVER_IPS[$i]=$SERVER_IP
		done

		for (( i=1; i<=SERVER_COUNT; i++ )); do
			echo -e "adapter\t${SERVER_IPS[$i]}\t${SERVER_HOSTNAMES[$i]}" >> /var/tmp/components.txt
		done

		if [ "$COMPONENT" == "5" ]; then
			PC_HOSTNAME=""
			while [[ -z "$PC_HOSTNAME" || ! "$PC_HOSTNAME" =~ ^[a-zA-Z0-9._-]+$ ]]; do
				echo -e "\nENTER PICO HOSTNAME: \c"
				read -r PC_HOSTNAME
			done
			PCIP=""
			while [[ ! $PCIP =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; do
				echo -e "ENTER PICO IP: \c"
				read -r PCIP
			done
			echo -e "pico\t$PCIP\t$PC_HOSTNAME" >> /var/tmp/components.txt
		fi

		echo -e "----------------------------------------------------------------------------------\n" | tee -a /var/tmp/prechecks.log
	fi

	echo -e "\nTesting connection with ${1} IP:\n" | tee -a /var/tmp/prechecks.log

	ip_addresses=$(cat /var/tmp/components.txt | grep -i ${1} | awk '{ print $2 }')	
	for i in $ip_addresses;
	do
		printf "Connectivity with $i on port 22\n" | tee -a /var/tmp/prechecks.log
		nc -z -v $i 22
		nc -z -v $i 22 &>> /var/tmp/prechecks.log
	done

	echo -e "\nTesting connection with ${1} Hostname:\n" | tee -a /var/tmp/prechecks.log
	
	hostname_list=$(cat /var/tmp/components.txt | grep -i ${1} | awk '{ print $3 }')
	for j in $hostname_list;
	do
		hip=$(dig $j +short)
		printf "Connectivity with $j ($hip) on port 22\n" | tee -a /var/tmp/prechecks.log
		nc -z -v $j 22
		nc -z -v $j 22 &>> /var/tmp/prechecks.log
	done
}

pipo_connectivity() {
	
	echo -e "\nTesting port connectivity with Adapter IP:\n" | tee -a /var/tmp/prechecks.log

	ip_addresses=$(cat /var/tmp/components.txt | grep -i "adapter" | awk '{ print $2 }')	
	for i in $ip_addresses;
	do
		printf "Connectivity with $i on port 7426\n" | tee -a /var/tmp/prechecks.log
		nc -z -v $i 7426
		nc -z -v $i 7426 &>> /var/tmp/prechecks.log
	done
	
	echo -e "\nTesting port connectivity with Adapter Hostname:\n" | tee -a /var/tmp/prechecks.log

	hostname_list=$(cat /var/tmp/components.txt | grep -i "adapter" | awk '{ print $3 }')
	for j in $hostname_list;
	do
		printf "Connectivity with $j on port 7426\n" | tee -a /var/tmp/prechecks.log
		nc -z -v $j 7426 
		nc -z -v $j 7426 &>> /var/tmp/prechecks.log
	done
	
	echo -e "----------------------------------------------------------------------------------\n" | tee -a /var/tmp/prechecks.log

	echo -e "\nTesting port connectivity with Core IP:\n" | tee -a /var/tmp/prechecks.log
	cip=$(cat /var/tmp/components.txt | grep -i "core" | awk '{ print $2 }')	
	for k in $cip;
	do
		printf "Connectivity with $k on port 1443\n" | tee -a /var/tmp/prechecks.log
			nc -z -v $k 1443 
			nc -z -v $k 1443 &>> /var/tmp/prechecks.log
		printf "Connectivity with $k on port 8086\n" | tee -a /var/tmp/prechecks.log
			nc -z -v $k 8086 
			nc -z -v $k 8086 &>> /var/tmp/prechecks.log
		printf "Connectivity with $k on port 8765\n" | tee -a /var/tmp/prechecks.log
			nc -z -v $k 8765 
			nc -z -v $k 8765 &>> /var/tmp/prechecks.log
	done
	
	echo -e "\nTesting port connectivity with Core Hostname:\n" | tee -a /var/tmp/prechecks.log
	chn=$(cat /var/tmp/components.txt | grep -i "core" | awk '{ print $3 }')
	for l in $chn;
	do
		printf "Connectivity with $l on port 1443\n" | tee -a /var/tmp/prechecks.log
			nc -z -v $l 1443 
			nc -z -v $l 1443 &>> /var/tmp/prechecks.log
		printf "Connectivity with $l on port 8086\n" | tee -a /var/tmp/prechecks.log
			nc -z -v $l 8086 
			nc -z -v $l 8086 &>> /var/tmp/prechecks.log
		printf "Connectivity with $l on port 8765\n" | tee -a /var/tmp/prechecks.log
			nc -z -v $l 8765 
			nc -z -v $l 8765 &>> /var/tmp/prechecks.log
	done

}

# ram_check() function is for checking the ram provided to the component according to thier deployment environment
ram_check() {
	sysram=$(free -g | awk '/Mem:/ {print $2}')
	sysramg=$(free -h | awk '/Mem:/ {print $2}')
	echo -e "Checking RAM provided to the server:\n" | tee -a /var/tmp/prechecks.log
	if [[ "$ENVIR" == "1" ]]; then
		if [ "$COMPONENT" == "1" ]; then
			if [ $sysram -ge "16" ]; then
				echo "RAM Check Passed the Minimum Configuration for Test Environment" | tee -a /var/tmp/prechecks.log
				echo "RAM provided: $sysramg" | tee -a /var/tmp/prechecks.log
			else
				echo "RAM Check Failed the Minimum Configuration for Test Environment" | tee -a /var/tmp/prechecks.log
				echo "RAM provided: $sysramg. It should be atleast 16GB" | tee -a /var/tmp/prechecks.log
			fi
		fi
		if [ "$COMPONENT" == "2" ]; then
			if [ $sysram -ge "16" ]; then
				echo "RAM Check Passed the Minimum Configuration for Test Environment" | tee -a /var/tmp/prechecks.log
				echo "RAM provided: $sysramg" | tee -a /var/tmp/prechecks.log
			else
				echo "RAM Check Failed the Minimum Configuration for Test Environment" | tee -a /var/tmp/prechecks.log
				echo "RAM provided: $sysramg. It should be atleast 16GB" | tee -a /var/tmp/prechecks.log
			fi
		fi
		if [ "$COMPONENT" == "3" ]; then
			if [ $sysram -ge "48" ]; then
				echo "RAM Check Passed the Minimum Configuration for Test Environment" | tee -a /var/tmp/prechecks.log
				echo "RAM provided: $sysramg" | tee -a /var/tmp/prechecks.log
			else
				echo "RAM Check Failed the Minimum Configuration for Test Environment" | tee -a /var/tmp/prechecks.log
				echo "RAM provided: $sysramg. It should be atleast 48GB" | tee -a /var/tmp/prechecks.log
			fi
		fi
		if [ "$COMPONENT" == "4" ]; then
			if [ $sysram -ge "16" ]; then
				echo "RAM Check Passed the Minimum Configuration for Test Environment" | tee -a /var/tmp/prechecks.log
				echo "RAM provided: $sysramg" | tee -a /var/tmp/prechecks.log
			else
				echo "RAM Check Failed the Minimum Configuration for Test Environment" | tee -a /var/tmp/prechecks.log
				echo "RAM provided: $sysramg. It should be atleast 16GB" | tee -a /var/tmp/prechecks.log
			fi
		fi
		if [ "$COMPONENT" == "5" ]; then
			if [ $sysram -ge "16" ]; then
				echo "RAM Check Passed the Minimum Configuration for Test Environment" | tee -a /var/tmp/prechecks.log
				echo "RAM provided: $sysramg" | tee -a /var/tmp/prechecks.log
			else
				echo "RAM Check Failed the Minimum Configuration for Test Environment" | tee -a /var/tmp/prechecks.log
				echo "RAM provided: $sysramg. It should be atleast 16GB" | tee -a /var/tmp/prechecks.log
			fi
		fi
	elif [ "$ENVIR" == "2" ]; then
		if [ "$COMPONENT" == "1" ]; then
			if [ $sysram -ge "32" ]; then
				echo "RAM Check Passed the Minimum Configuration for Production Environment" | tee -a /var/tmp/prechecks.log
				echo "RAM provided: $sysramg" | tee -a /var/tmp/prechecks.log
			else
				echo "RAM Check Failed the Minimum Configuration for Production Environment" | tee -a /var/tmp/prechecks.log
				echo "RAM provided: $sysramg. It should be atleast 32GB" | tee -a /var/tmp/prechecks.log
			fi
		fi
		if [ "$COMPONENT" == "2" ]; then
			if [ $sysram -ge "32" ]; then
				echo "RAM Check Passed the Minimum Configuration for Production Environment" | tee -a /var/tmp/prechecks.log
				echo "RAM provided: $sysramg" | tee -a /var/tmp/prechecks.log
			else
				echo "RAM Check Failed the Minimum Configuration for Production Environment" | tee -a /var/tmp/prechecks.log
				echo "RAM provided: $sysramg. It should be atleast 32GB"  | tee -a /var/tmp/prechecks.log
			fi
		fi
		if [ "$COMPONENT" == "3" ]; then
			if [ $sysram -ge "64" ]; then
				echo "RAM Check Passed the Minimum Configuration for Production Environment" | tee -a /var/tmp/prechecks.log
				echo "RAM provided: $sysramg" | tee -a /var/tmp/prechecks.log
			else
				echo "RAM Check Failed the Minimum Configuration for Production Environment" | tee -a /var/tmp/prechecks.log
				echo "RAM provided: $sysramg. It should be atleast 64GB" | tee -a /var/tmp/prechecks.log
			fi
		fi
		if [ "$COMPONENT" == "4" ]; then
			if [ $sysram -ge "32" ]; then
				echo "RAM Check Passed the Minimum Configuration for Production Environment" | tee -a /var/tmp/prechecks.log
				echo "RAM provided: $sysramg" | tee -a /var/tmp/prechecks.log
			else
				echo "RAM Check Failed the Minimum Configuration for Production Environment" | tee -a /var/tmp/prechecks.log
				echo "RAM provided: $sysramg. It should be atleast 32GB" | tee -a /var/tmp/prechecks.log
			fi
		fi
		if [ "$COMPONENT" == "5" ]; then
			if [ $sysram -ge "32" ]; then
				echo "RAM Check Passed the Minimum Configuration for Production Environment" | tee -a /var/tmp/prechecks.log
				echo "RAM provided: $sysramg" | tee -a /var/tmp/prechecks.log
			else
				echo "RAM Check Failed the Minimum Configuration for Production Environment" | tee -a /var/tmp/prechecks.log
				echo "RAM provided: $sysramg. It should be atleast 32GB" | tee -a /var/tmp/prechecks.log
			fi
		fi
	fi
}

# cpu_check() function is for checking the vcpu provided to the component according to thier deployment environment
cpu_check() {
	syscpu=$(nproc)
	echo -e "Checking vCPU provided to the server:\n" | tee -a /var/tmp/prechecks.log
	if [[ "$ENVIR" == "1" ]]; then
		if [ "$COMPONENT" == "1" ]; then
			if [ $syscpu -ge "8" ]; then
				echo "vCPU Check Passed the Minimum Configuration for Test Environment" | tee -a /var/tmp/prechecks.log
				echo "vCPU provided: $syscpu" | tee -a /var/tmp/prechecks.log
			else
				echo "vCPU Check Failed the Minimum Configuration for Test Environment" | tee -a /var/tmp/prechecks.log
				echo "vCPU provided: $syscpu. It should be atleast 8vCPU" | tee -a /var/tmp/prechecks.log
			fi
		fi
		if [ "$COMPONENT" == "2" ]; then
			if [ $syscpu -ge "8" ]; then
				echo "vCPU Check Passed the Minimum Configuration for Test Environment" | tee -a /var/tmp/prechecks.log
				echo "vCPU provided: $syscpu" | tee -a /var/tmp/prechecks.log
			else
				echo "vCPU Check Failed the Minimum Configuration for Test Environment" | tee -a /var/tmp/prechecks.log
				echo "vCPU provided: $syscpu. It should be atleast 8vCPU" | tee -a /var/tmp/prechecks.log
			fi
		fi
		if [ "$COMPONENT" == "3" ]; then
			if [ $syscpu -ge "24" ]; then
				echo "vCPU Check Passed the Minimum Configuration for Test Environment" | tee -a /var/tmp/prechecks.log
				echo "vCPU provided: $syscpu" | tee -a /var/tmp/prechecks.log
			else
				echo "vCPU Check Failed the Minimum Configuration for Test Environment" | tee -a /var/tmp/prechecks.log
				echo "vCPU provided: $syscpu. It should be atleast 24vCPU" | tee -a /var/tmp/prechecks.log
			fi
		fi
		if [ "$COMPONENT" == "4" ]; then
			if [ $syscpu -ge "8" ]; then
				echo "vCPU Check Passed the Minimum Configuration for Test Environment" | tee -a /var/tmp/prechecks.log
				echo "vCPU provided: $syscpu" | tee -a /var/tmp/prechecks.log
			else
				echo "vCPU Check Failed the Minimum Configuration for Test Environment" | tee -a /var/tmp/prechecks.log
				echo "vCPU provided: $syscpu. It should be atleast 8vCPU" | tee -a /var/tmp/prechecks.log
			fi
		fi
		if [ "$COMPONENT" == "5" ]; then
			if [ $syscpu -ge "8" ]; then
				echo "vCPU Check Passed the Minimum Configuration for Test Environment" | tee -a /var/tmp/prechecks.log
				echo "vCPU provided: $syscpu" | tee -a /var/tmp/prechecks.log
			else
				echo "vCPU Check Failed the Minimum Configuration for Test Environment" | tee -a /var/tmp/prechecks.log
				echo "vCPU provided: $syscpu. It should be atleast 8vCPU" | tee -a /var/tmp/prechecks.log
			fi
		fi
	elif [ "$ENVIR" == "2" ]; then
		if [ "$COMPONENT" == "1" ]; then
			if [ $syscpu -ge "16" ]; then
				echo "vCPU Check Passed the Minimum Configuration for Production Environment" | tee -a /var/tmp/prechecks.log
				echo "vCPU provided: $syscpu" | tee -a /var/tmp/prechecks.log
			else
				echo "vCPU Check Failed the Minimum Configuration for Production Environment" | tee -a /var/tmp/prechecks.log
				echo "vCPU provided: $syscpu. It should be atleast 16vCPU" | tee -a /var/tmp/prechecks.log
			fi
		fi
		if [ "$COMPONENT" == "2" ]; then
			if [ $syscpu -ge "16" ]; then
				echo "vCPU Check Passed the Minimum Configuration for Production Environment" | tee -a /var/tmp/prechecks.log
				echo "vCPU provided: $syscpu" | tee -a /var/tmp/prechecks.log
			else
				echo "vCPU Check Failed the Minimum Configuration for Production Environment" | tee -a /var/tmp/prechecks.log
				echo "vCPU provided: $syscpu. It should be atleast 16vCPU" | tee -a /var/tmp/prechecks.log
			fi
		fi
		if [ "$COMPONENT" == "3" ]; then
			if [ $syscpu -ge "32" ]; then
				echo "vCPU Check Passed the Minimum Configuration for Production Environment" | tee -a /var/tmp/prechecks.log
				echo "vCPU provided: $syscpu" | tee -a /var/tmp/prechecks.log
			else
				echo "vCPU Check Failed the Minimum Configuration for Production Environment" | tee -a /var/tmp/prechecks.log
				echo "vCPU provided: $syscpu. It should be atleast 32vCPU" | tee -a /var/tmp/prechecks.log
			fi
		fi
		if [ "$COMPONENT" == "4" ]; then
			if [ $syscpu -ge "16" ]; then
				echo "vCPU Check Passed the Minimum Configuration for Production Environment" | tee -a /var/tmp/prechecks.log
				echo "vCPU provided: $syscpu" | tee -a /var/tmp/prechecks.log
			else
				echo "vCPU Check Failed the Minimum Configuration for Production Environment" | tee -a /var/tmp/prechecks.log
				echo "vCPU provided: $syscpu. It should be atleast 16vCPU" | tee -a /var/tmp/prechecks.log
			fi
		fi
		if [ "$COMPONENT" == "5" ]; then
			if [ $syscpu -ge "16" ]; then
				echo "vCPU Check Passed the Minimum Configuration for Production Environment" | tee -a /var/tmp/prechecks.log
				echo "vCPU provided: $syscpu" | tee -a /var/tmp/prechecks.log
			else
				echo "vCPU Check Failed the Minimum Configuration for Production Environment" | tee -a /var/tmp/prechecks.log
				echo "vCPU provided: $syscpu. It should be atleast 16vCPU" | tee -a /var/tmp/prechecks.log
			fi
		fi
	fi

	echo -e "\nlscpu output:" | tee -a /var/tmp/prechecks.log
	echo $(lscpu | grep "CPU(s):" | grep -v "NUMA node0") | tee -a /var/tmp/prechecks.log
	echo $(lscpu | grep "On-line CPU(s) list:") | tee -a /var/tmp/prechecks.log
	echo $(lscpu | grep "Thread(s) per core:") | tee -a /var/tmp/prechecks.log
	echo $(lscpu | grep "Core(s) per socket:") | tee -a /var/tmp/prechecks.log
	echo $(lscpu | grep "Socket(s):") | tee -a /var/tmp/prechecks.log

}


# store_check() function is for checking the "/DNIF" partition size provided to the component according to thier deployment environment
#it will also check if the root "/" partition of minimum 200GB is provided or not. 
store_check() {

	rsizeik=$(df -k / | awk '/dev/ {print $2}')
	rootsize=$(df -h / | awk '/dev/ {print $2}')
	HOS=$(lsblk -o ROTA,MOUNTPOINT | grep -i "DNIF" | awk '{ print $1 }')
	echo -e "Checking ""/DNIF"" partition size provided to the server:\n" | tee -a /var/tmp/prechecks.log
	if [[ ! -z "$(df -h | grep "/DNIF")" ]]; then
		dsizeik=$(df -k /DNIF | awk '/dev/ {print $2}')
		dnifsize=$(df -h /DNIF | awk '/dev/ {print $2}')
		if [[ "$ENVIR" == "1" ]]; then
			if [ "$COMPONENT" == "1" ]; then
				if [ $dsizeik -ge "524288000" ]; then
					echo "/DNIF Partition Check Passed the Minimum Configuration for Test Environment" | tee -a /var/tmp/prechecks.log
					echo "/DNIF Partition provided: $dnifsize" | tee -a /var/tmp/prechecks.log
				else
					echo "/DNIF Partition Check Failed the Minimum Configuration for Test Environment" | tee -a /var/tmp/prechecks.log
					echo "/DNIF Partition provided: $dnifsize. It should be atleast 500GB" | tee -a /var/tmp/prechecks.log
				fi
			fi
			if [ "$COMPONENT" == "2" ]; then
				if [ $dsizeik -ge "335544320" ]; then
					echo "/DNIF Partition Check Passed the Minimum Configuration for Test Environment" | tee -a /var/tmp/prechecks.log
					echo "/DNIF Partition provided: $dnifsize" | tee -a /var/tmp/prechecks.log
				else
					echo "/DNIF Partition Check Failed the Minimum Configuration for Test Environment" | tee -a /var/tmp/prechecks.log
					echo "/DNIF Partition provided: $dnifsize. It should be atleast 320GB" | tee -a /var/tmp/prechecks.log
				fi
			fi
			if [ "$COMPONENT" == "3" ]; then
				if [ $dsizeik -ge "524288000" ]; then
					echo "/DNIF Partition Check Passed the Minimum Configuration for Test Environment" | tee -a /var/tmp/prechecks.log
					echo "/DNIF Partition provided: $dnifsize" | tee -a /var/tmp/prechecks.log
				else
					echo "/DNIF Partition Check Failed the Minimum Configuration for Test Environment" | tee -a /var/tmp/prechecks.log
					echo "/DNIF Partition provided: $dnifsize. It should be atleast 500GB" | tee -a /var/tmp/prechecks.log
				fi
			fi
			if [ "$COMPONENT" == "4" ]; then
				if [ $dsizeik -ge "335544320" ]; then
					echo "/DNIF Partition Check Passed the Minimum Configuration for Test Environment" | tee -a /var/tmp/prechecks.log
					echo "/DNIF Partition provided: $dnifsize" | tee -a /var/tmp/prechecks.log
				else
					echo "/DNIF Partition Check Failed the Minimum Configuration for Test Environment" | tee -a /var/tmp/prechecks.log
					echo "/DNIF Partition provided: $dnifsize. It should be atleast 320GB" | tee -a /var/tmp/prechecks.log
				fi
			fi
			if [ "$COMPONENT" == "5" ]; then
				if [ $dsizeik -ge "335544320" ]; then
					echo "/DNIF Partition Check Passed the Minimum Configuration for Test Environment" | tee -a /var/tmp/prechecks.log
					echo "/DNIF Partition provided: $dnifsize" | tee -a /var/tmp/prechecks.log
				else
					echo "/DNIF Partition Check Failed the Minimum Configuration for Test Environment" | tee -a /var/tmp/prechecks.log
					echo "/DNIF Partition provided: $dnifsize. It should be atleast 320GB" | tee -a /var/tmp/prechecks.log
				fi
			fi
		elif [ "$ENVIR" == "2" ]; then
			if [ "$COMPONENT" == "1" ]; then
				if [  $dsizeik -ge "1048576000" ]; then
					echo "/DNIF Partition Check Passed the Minimum Configuration for Production Environment" | tee -a /var/tmp/prechecks.log
					echo "/DNIF Partition provided: $dnifsize" | tee -a /var/tmp/prechecks.log
				else
					echo "/DNIF Partition Check Failed the Minimum Configuration for Production Environment" | tee -a /var/tmp/prechecks.log
					echo "/DNIF Partition provided: $dnifsize. It should be atleast 1TB" | tee -a /var/tmp/prechecks.log
				fi
			fi
			if [ "$COMPONENT" == "2" ]; then
				if [  $dsizeik -ge "335544320" ]; then
					echo "/DNIF Partition Check Passed the Minimum Configuration for Production Environment" | tee -a /var/tmp/prechecks.log
					echo "/DNIF Partition provided: $dnifsize" | tee -a /var/tmp/prechecks.log
				else
					echo "/DNIF Partition Check Failed the Minimum Configuration for Production Environment" | tee -a /var/tmp/prechecks.log
					echo "/DNIF Partition provided: $dnifsize. It should be atleast 320GB" | tee -a /var/tmp/prechecks.log
				fi
			fi
			if [ "$COMPONENT" == "3" ]; then
				if [  $dsizeik -ge "524288000" ]; then
					echo "/DNIF Partition Check Passed the Minimum Configuration for Production Environment" | tee -a /var/tmp/prechecks.log
					echo "/DNIF Partition provided: $dnifsize" | tee -a /var/tmp/prechecks.log
				else
					echo "/DNIF Partition Check Failed the Minimum Configuration for Production Environment" | tee -a /var/tmp/prechecks.log
					echo "/DNIF Partition provided: $dnifsize. It should be atleast 500GB" | tee -a /var/tmp/prechecks.log
				fi
			fi
			if [ "$COMPONENT" == "4" ]; then
				if [  $dsizeik -ge "335544320" ]; then
					echo "/DNIF Partition Check Passed the Minimum Configuration for Production Environment" | tee -a /var/tmp/prechecks.log
					echo "/DNIF Partition provided: $dnifsize" | tee -a /var/tmp/prechecks.log
				else
					echo "/DNIF Partition Check Failed the Minimum Configuration for Production Environment" | tee -a /var/tmp/prechecks.log
					echo "/DNIF Partition provided: $dnifsize. It should be atleast 320GB" | tee -a /var/tmp/prechecks.log
				fi
			fi
			if [ "$COMPONENT" == "5" ]; then
				if [  $dsizeik -ge "335544320" ]; then
					echo "/DNIF Partition Check Passed the Minimum Configuration for Production Environment" | tee -a /var/tmp/prechecks.log
					echo "/DNIF Partition provided: $dnifsize" | tee -a /var/tmp/prechecks.log
				else
					echo "/DNIF Partition Check Failed the Minimum Configuration for Production Environment" | tee -a /var/tmp/prechecks.log
					echo "/DNIF Partition provided: $dnifsize. It should be atleast 320GB" | tee -a /var/tmp/prechecks.log
				fi
			fi
		fi
	else
		echo -e "The ""/DNIF"" Partition is not provided " | tee -a /var/tmp/prechecks.log
	fi

	echo -e "----------------------------------------------------------------------------------\n" | tee -a /var/tmp/prechecks.log

	echo -e "Checking ROOT partition size provided to the server:\n" | tee -a /var/tmp/prechecks.log
	if [ $rsizeik -ge "209715200" ]; then
		echo "Root '/' Partition Check Passed the Minimum Configuration" | tee -a /var/tmp/prechecks.log
		echo "Root '/' Partition provided: $rootsize" | tee -a /var/tmp/prechecks.log
	else
		echo "Root '/' Partition Check Failed the Minimum Configuration" | tee -a /var/tmp/prechecks.log
		echo "Root '/' Partition provided: $rootsize. It should be atleast 200GB" | tee -a /var/tmp/prechecks.log
	fi

    echo -e "----------------------------------------------------------------------------------\n" | tee -a /var/tmp/prechecks.log

	echo -e "Checking /DNIF Storage Type (HDD/SSD):\n" | tee -a /var/tmp/prechecks.log
	if [[ $HOS == "1" ]]; then
		echo "The Provided ""/DNIF"" Partition is HDD" | tee -a /var/tmp/prechecks.log
	elif [[ $HOS == "0" ]]; then
		echo "The Provided ""/DNIF"" Partition is SSD " | tee -a /var/tmp/prechecks.log
	else
		echo "The ""/DNIF"" Partition is not provided " | tee -a /var/tmp/prechecks.log
	fi

}

#Port connectivity checks
port_connectivity() {

	echo -e "PORT Prerequisites:\n" | tee -a /var/tmp/prechecks.log
	PORT=(80 22)
	for port in "${PORT[@]}";
	do
		if timeout 15 bash -c "</dev/tcp/localhost/$port" &> /dev/null
		then
			printf "Port $port .....................................................Open\n" | tee -a /var/tmp/prechecks.log
		else
			printf "Port $port .....................................................Closed\n" | tee -a /var/tmp/prechecks.log
		fi
	done
}

#URL connectivity checks
url_connectivity() {
	echo -e "Connectivity Statistics:\n" | tee -a /var/tmp/prechecks.log
	for site in  https://github.com/ https://raw.githubusercontent.com/ https://hub.docker.com/ https://www.docker.io/ https://hog.dnif.it/
	do
		if wget -O - -q -t 1 --timeout=6 --spider -S "$site" 2>&1 | grep -w "200\|301" ; then
	    	printf "Connectivity with $site.................................Passed \n" | tee -a /var/tmp/prechecks.log
		else
	    	printf "Connectivity with $site.................................Failed \n" | tee -a /var/tmp/prechecks.log
		fi
	done
}

#Checking selinux status
selinux_check() {

	echo -e "Checking SELinux status:\n"  | tee -a /var/tmp/prechecks.log
	if [ ! -f "/usr/sbin/sestatus" ]; then
		echo "policycoreutils is not installed" | tee -a /var/tmp/prechecks.log
	else
		sestatus | tee -a /var/tmp/prechecks.log
	fi
}

#Checking Proxy on the server
proxy_check() {
  
        echo -e "Checking Proxy:\n" | tee -a /var/tmp/prechecks.log
        if [ -z "$(env | grep -i "proxy")" ]; then
                echo "No proxy found on the server" | tee -a /var/tmp/prechecks.log
        elif [[ ! -z "$(env | grep -i "proxy")" ]]; then
                echo -e "Proxy found on the server:\n" | tee -a /var/tmp/prechecks.log
                envis=$(env | grep -i "proxy")
                echo ${envis} | tee -a /var/tmp/prechecks.log
        fi
}

if [ -r /etc/os-release ]; then
	os="$(. /etc/os-release && echo "$ID")"
fi

#Checking firewall status
firewall_check() {

	echo -e "Checking Firewall status:\n"  | tee -a /var/tmp/prechecks.log
	if [ $os == 'ubuntu' ]; then
		ufw status | tee -a /var/tmp/prechecks.log
		# Check if firewalld is installed
		if systemctl list-unit-files | grep -q firewalld.service; then
			echo "firewalld service is installed." | tee -a /var/tmp/prechecks.log

			# Check if it's active
			if systemctl is-active --quiet firewalld; then
				echo "firewalld service is active." | tee -a /var/tmp/prechecks.log
			else
				echo "firewalld service is installed but not active." | tee -a /var/tmp/prechecks.log
			fi
		else
			echo "firewalld service is not installed on this system." | tee -a /var/tmp/prechecks.log
		fi
	else
		systemctl status firewalld | tee -a /var/tmp/prechecks.log
	fi
}

#Checking sysbench status
sysbench_check() {
	
	echo -e "Checking sysbench status:\n"  | tee -a /var/tmp/prechecks.log
	if command -v sysbench >/dev/null 2>&1; then
        echo "Sysbench is already installed." | tee -a /var/tmp/prechecks.log
    else
        echo "sysbench not found. Attempting to install..." | tee -a /var/tmp/prechecks.log
        if [[ "$os" == "ubuntu" ]]; then
            sudo apt update &>> /var/tmp/prechecks.log
            sudo apt install -y sysbench &>> /var/tmp/prechecks.log
        elif [[ "$os" == "rhel" || "$os" == "centos" ]]; then
            # Prefer dnf if available
            if command -v dnf >/dev/null 2>&1; then
                sudo dnf install -y sysbench &>> /var/tmp/prechecks.log
            else
                sudo yum install -y sysbench &>> /var/tmp/prechecks.log
            fi
        fi
        # Verify installation
        if command -v sysbench >/dev/null 2>&1; then
            echo "sysbench successfully installed." | tee -a /var/tmp/prechecks.log
        else
            echo "Failed to install sysbench." | tee -a /var/tmp/prechecks.log
            exit 1
        fi
    fi
	hb_status=""
	# Prompt for hb_status (yes/no)
	while [[ "$hb_status" != "yes" && "$hb_status" != "no" ]]; do
		echo -n "Do you want to perform Hardware Benchmarking (yes/no): " | tee -a /var/tmp/prechecks.log
		read -r hb_status
		echo -e $hb_status >> /var/tmp/prechecks.log
	done
	if [[ "$hb_status" == "yes" ]]; then
		cd /DNIF/
		echo -e "-------------------------------------------\n" | tee -a /var/tmp/prechecks.log
		echo -e "Starting CPU Benchmarking :" | tee -a /var/tmp/prechecks.log
		echo -e "-------------------------------------------\n" | tee -a /var/tmp/prechecks.log
		echo -e "CPU Benchmarking using a single thread :-\n" | tee -a /var/tmp/prechecks.log
		sysbench --test=cpu --num-threads=1 --cpu-max-prime=20000 run | tee -a /var/tmp/prechecks.log
		echo -e "-------------------------------------------\n" | tee -a /var/tmp/prechecks.log
		echo -e "CPU Benchmarking using multiple (we will use 8) threads :-\n" | tee -a /var/tmp/prechecks.log
		sysbench --test=cpu --num-threads=8 --cpu-max-prime=20000 run | tee -a /var/tmp/prechecks.log
		echo -e "-------------------------------------------\n" | tee -a /var/tmp/prechecks.log
		echo -e "Starting Memory Benchmarking :" | tee -a /var/tmp/prechecks.log
		echo -e "-------------------------------------------\n" | tee -a /var/tmp/prechecks.log
		echo -e "Benchmarking memory using a single thread :-\n" | tee -a /var/tmp/prechecks.log
		sysbench --test=memory --num-threads=1 run | tee -a /var/tmp/prechecks.log
		echo -e "-------------------------------------------\n" | tee -a /var/tmp/prechecks.log
		echo -e "Benchmarking memory using multiple (we will use 8) threads :-\n" | tee -a /var/tmp/prechecks.log
		sysbench --test=memory --num-threads=8 run | tee -a /var/tmp/prechecks.log
		echo -e "-------------------------------------------\n" | tee -a /var/tmp/prechecks.log
		echo -e "Starting File IO Benchmarking :" | tee -a /var/tmp/prechecks.log
		echo -e "-------------------------------------------\n" | tee -a /var/tmp/prechecks.log
		echo -e "Preparing for benchmarking :-\n" | tee -a /var/tmp/prechecks.log
		sysbench --test=fileio --file-total-size=150G prepare | tee -a /var/tmp/prechecks.log
		echo -e "-------------------------------------------\n" | tee -a /var/tmp/prechecks.log
		echo -e "Conducting the test :-\n" | tee -a /var/tmp/prechecks.log
		sysbench --test=fileio --file-total-size=150G --file-test-mode=rndrw --max-requests=0 run | tee -a /var/tmp/prechecks.log
		echo -e "-------------------------------------------\n" | tee -a /var/tmp/prechecks.log
		echo -e "Cleaning up after the test :-\n" | tee -a /var/tmp/prechecks.log
		sysbench --test=fileio --file-total-size=150G cleanup | tee -a /var/tmp/prechecks.log
	fi
}

#-------------------------------------------------------CASE-------------------------------------------------------------

case "${COMPONENT^^}" in
	1)
		echo -e "----------------------------------------------------------------------------------" | tee -a /var/tmp/prechecks.log
		ip_connectivity "Core"
		echo -e "----------------------------------------------------------------------------------\n" | tee -a /var/tmp/prechecks.log
		ip_connectivity "Datanode"
		echo -e "----------------------------------------------------------------------------------\n" | tee -a /var/tmp/prechecks.log
		ip_connectivity "Adapter"
		echo -e "----------------------------------------------------------------------------------\n" | tee -a /var/tmp/prechecks.log
		ip_connectivity "Console"
		echo -e "----------------------------------------------------------------------------------\n" | tee -a /var/tmp/prechecks.log
		ram_check
		echo -e "----------------------------------------------------------------------------------\n" | tee -a /var/tmp/prechecks.log
		cpu_check
		echo -e "----------------------------------------------------------------------------------\n" | tee -a /var/tmp/prechecks.log
		store_check
		echo -e "----------------------------------------------------------------------------------\n" | tee -a /var/tmp/prechecks.log
		echo -e "Current Server Time:\n" | tee -a /var/tmp/prechecks.log
		timedatectl | tee -a /var/tmp/prechecks.log
		echo -e "----------------------------------------------------------------------------------\n" | tee -a /var/tmp/prechecks.log
		echo -e "Network interface configuration:\n" | tee -a /var/tmp/prechecks.log
		ifconfig | tee -a /var/tmp/prechecks.log
		echo -e "----------------------------------------------------------------------------------\n" | tee -a /var/tmp/prechecks.log
		echo -e "cat /etc/hosts file:\n" | tee -a /var/tmp/prechecks.log
		cat /etc/hosts | tee -a /var/tmp/prechecks.log
		echo -e "----------------------------------------------------------------------------------\n" | tee -a /var/tmp/prechecks.log
		port_connectivity
		echo -e "----------------------------------------------------------------------------------\n" | tee -a /var/tmp/prechecks.log
		url_connectivity
		echo -e "----------------------------------------------------------------------------------\n" | tee -a /var/tmp/prechecks.log
		selinux_check
		echo -e "----------------------------------------------------------------------------------\n" | tee -a /var/tmp/prechecks.log
		echo -e "umask:\n" | tee -a /var/tmp/prechecks.log
		umask | tee -a /var/tmp/prechecks.log
		echo -e "----------------------------------------------------------------------------------\n" | tee -a /var/tmp/prechecks.log
		proxy_check
		echo -e "----------------------------------------------------------------------------------\n" | tee -a /var/tmp/prechecks.log
		firewall_check
		echo -e "----------------------------------------------------------------------------------\n" | tee -a /var/tmp/prechecks.log
		sysbench_check
		echo -e "----------------------------------------------------------------------------------" | tee -a /var/tmp/prechecks.log
		;;
	2)
		echo -e "----------------------------------------------------------------------------------" | tee -a /var/tmp/prechecks.log
		ip_connectivity "Core"
		echo -e "----------------------------------------------------------------------------------\n" | tee -a /var/tmp/prechecks.log
		ip_connectivity "Datanode"
		echo -e "----------------------------------------------------------------------------------\n" | tee -a /var/tmp/prechecks.log
		ip_connectivity "Adapter"
		echo -e "----------------------------------------------------------------------------------\n" | tee -a /var/tmp/prechecks.log
		ip_connectivity "Console"
		echo -e "----------------------------------------------------------------------------------\n" | tee -a /var/tmp/prechecks.log
		ram_check
		echo -e "----------------------------------------------------------------------------------\n" | tee -a /var/tmp/prechecks.log
		cpu_check
		echo -e "----------------------------------------------------------------------------------\n" | tee -a /var/tmp/prechecks.log
		store_check
		echo -e "----------------------------------------------------------------------------------\n" | tee -a /var/tmp/prechecks.log
		echo -e "Current Server Time:\n" | tee -a /var/tmp/prechecks.log
		timedatectl | tee -a /var/tmp/prechecks.log
		echo -e "----------------------------------------------------------------------------------\n" | tee -a /var/tmp/prechecks.log
		echo -e "Network interface configuration:\n" | tee -a /var/tmp/prechecks.log
		ifconfig | tee -a /var/tmp/prechecks.log
		echo -e "----------------------------------------------------------------------------------\n" | tee -a /var/tmp/prechecks.log
		echo -e "cat /etc/hosts file:\n" | tee -a /var/tmp/prechecks.log
		cat /etc/hosts | tee -a /var/tmp/prechecks.log
		echo -e "----------------------------------------------------------------------------------\n" | tee -a /var/tmp/prechecks.log
		port_connectivity
		echo -e "----------------------------------------------------------------------------------\n" | tee -a /var/tmp/prechecks.log
		url_connectivity
		echo -e "----------------------------------------------------------------------------------\n" | tee -a /var/tmp/prechecks.log
		selinux_check
		echo -e "----------------------------------------------------------------------------------\n" | tee -a /var/tmp/prechecks.log
		echo -e "umask:\n" | tee -a /var/tmp/prechecks.log
		umask | tee -a /var/tmp/prechecks.log
		echo -e "----------------------------------------------------------------------------------\n" | tee -a /var/tmp/prechecks.log
		proxy_check
		echo -e "----------------------------------------------------------------------------------\n" | tee -a /var/tmp/prechecks.log
		firewall_check
		echo -e "----------------------------------------------------------------------------------\n" | tee -a /var/tmp/prechecks.log
		sysbench_check
		echo -e "----------------------------------------------------------------------------------" | tee -a /var/tmp/prechecks.log
		;;
	3)
		echo -e "----------------------------------------------------------------------------------" | tee -a /var/tmp/prechecks.log
		ip_connectivity "Core"
		echo -e "----------------------------------------------------------------------------------\n" | tee -a /var/tmp/prechecks.log
		ip_connectivity "Datanode"
		echo -e "----------------------------------------------------------------------------------\n" | tee -a /var/tmp/prechecks.log
		ip_connectivity "Adapter"
		echo -e "----------------------------------------------------------------------------------\n" | tee -a /var/tmp/prechecks.log
		ip_connectivity "Console"
		echo -e "----------------------------------------------------------------------------------\n" | tee -a /var/tmp/prechecks.log
		ram_check
		echo -e "----------------------------------------------------------------------------------\n" | tee -a /var/tmp/prechecks.log
		cpu_check
		echo -e "----------------------------------------------------------------------------------\n" | tee -a /var/tmp/prechecks.log
		store_check
		echo -e "----------------------------------------------------------------------------------\n" | tee -a /var/tmp/prechecks.log
		echo -e "Current Server Time:\n" | tee -a /var/tmp/prechecks.log
		timedatectl | tee -a /var/tmp/prechecks.log
		echo -e "----------------------------------------------------------------------------------\n" | tee -a /var/tmp/prechecks.log
		echo -e "Network interface configuration:\n" | tee -a /var/tmp/prechecks.log
		ifconfig | tee -a /var/tmp/prechecks.log
		echo -e "----------------------------------------------------------------------------------\n" | tee -a /var/tmp/prechecks.log
		echo -e "cat /etc/hosts file:\n" | tee -a /var/tmp/prechecks.log
		cat /etc/hosts | tee -a /var/tmp/prechecks.log
		echo -e "----------------------------------------------------------------------------------\n" | tee -a /var/tmp/prechecks.log
		port_connectivity
		echo -e "----------------------------------------------------------------------------------\n" | tee -a /var/tmp/prechecks.log
		url_connectivity
		echo -e "----------------------------------------------------------------------------------\n" | tee -a /var/tmp/prechecks.log
		selinux_check
		echo -e "----------------------------------------------------------------------------------\n" | tee -a /var/tmp/prechecks.log
		echo -e "umask:\n" | tee -a /var/tmp/prechecks.log
		umask | tee -a /var/tmp/prechecks.log
		echo -e "----------------------------------------------------------------------------------\n" | tee -a /var/tmp/prechecks.log
		proxy_check
		echo -e "----------------------------------------------------------------------------------\n" | tee -a /var/tmp/prechecks.log
		firewall_check
		echo -e "----------------------------------------------------------------------------------\n" | tee -a /var/tmp/prechecks.log
		sysbench_check
		echo -e "----------------------------------------------------------------------------------" | tee -a /var/tmp/prechecks.log
		;;
	4)
		echo -e "----------------------------------------------------------------------------------" | tee -a /var/tmp/prechecks.log
		ip_connectivity "Core"
		echo -e "----------------------------------------------------------------------------------\n" | tee -a /var/tmp/prechecks.log
		ip_connectivity "Datanode"
		echo -e "----------------------------------------------------------------------------------\n" | tee -a /var/tmp/prechecks.log
		ip_connectivity "Adapter"
		echo -e "----------------------------------------------------------------------------------\n" | tee -a /var/tmp/prechecks.log
		ip_connectivity "Console"
		echo -e "----------------------------------------------------------------------------------\n" | tee -a /var/tmp/prechecks.log
		ram_check
		echo -e "----------------------------------------------------------------------------------\n" | tee -a /var/tmp/prechecks.log
		cpu_check
		echo -e "----------------------------------------------------------------------------------\n" | tee -a /var/tmp/prechecks.log
		store_check
		echo -e "----------------------------------------------------------------------------------\n" | tee -a /var/tmp/prechecks.log
		echo -e "Current Server Time:\n" | tee -a /var/tmp/prechecks.log
		timedatectl | tee -a /var/tmp/prechecks.log
		echo -e "----------------------------------------------------------------------------------\n" | tee -a /var/tmp/prechecks.log
		echo -e "Network interface configuration:\n" | tee -a /var/tmp/prechecks.log
		ifconfig | tee -a /var/tmp/prechecks.log
		echo -e "----------------------------------------------------------------------------------\n" | tee -a /var/tmp/prechecks.log
		echo -e "cat /etc/hosts file:\n" | tee -a /var/tmp/prechecks.log
		cat /etc/hosts | tee -a /var/tmp/prechecks.log
		echo -e "----------------------------------------------------------------------------------\n" | tee -a /var/tmp/prechecks.log
		port_connectivity
		echo -e "----------------------------------------------------------------------------------\n" | tee -a /var/tmp/prechecks.log
		url_connectivity
		echo -e "----------------------------------------------------------------------------------\n" | tee -a /var/tmp/prechecks.log
		selinux_check
		echo -e "----------------------------------------------------------------------------------\n" | tee -a /var/tmp/prechecks.log
		echo -e "umask:\n" | tee -a /var/tmp/prechecks.log
		umask | tee -a /var/tmp/prechecks.log
		echo -e "----------------------------------------------------------------------------------\n" | tee -a /var/tmp/prechecks.log
		proxy_check
		echo -e "----------------------------------------------------------------------------------\n" | tee -a /var/tmp/prechecks.log
		firewall_check
		echo -e "----------------------------------------------------------------------------------\n" | tee -a /var/tmp/prechecks.log
		sysbench_check
		echo -e "----------------------------------------------------------------------------------" | tee -a /var/tmp/prechecks.log
		;;
	5)
		echo -e "----------------------------------------------------------------------------------" | tee -a /var/tmp/prechecks.log
		ip_connectivity "Pico"
		echo -e "----------------------------------------------------------------------------------\n" | tee -a /var/tmp/prechecks.log
		ip_connectivity "Adapter"
		echo -e "----------------------------------------------------------------------------------\n" | tee -a /var/tmp/prechecks.log
		ip_connectivity "Core"
		echo -e "----------------------------------------------------------------------------------\n" | tee -a /var/tmp/prechecks.log
		ram_check
		echo -e "----------------------------------------------------------------------------------\n" | tee -a /var/tmp/prechecks.log
		cpu_check
		echo -e "----------------------------------------------------------------------------------\n" | tee -a /var/tmp/prechecks.log
		store_check
		echo -e "----------------------------------------------------------------------------------\n" | tee -a /var/tmp/prechecks.log
		echo -e "Current Server Time:\n" | tee -a /var/tmp/prechecks.log
		timedatectl | tee -a /var/tmp/prechecks.log
		echo -e "----------------------------------------------------------------------------------\n" | tee -a /var/tmp/prechecks.log
		echo -e "Network interface configuration:\n" | tee -a /var/tmp/prechecks.log
		ifconfig | tee -a /var/tmp/prechecks.log
		echo -e "----------------------------------------------------------------------------------\n" | tee -a /var/tmp/prechecks.log
		echo -e "cat /etc/hosts file:\n" | tee -a /var/tmp/prechecks.log
		cat /etc/hosts | tee -a /var/tmp/prechecks.log
		echo -e "----------------------------------------------------------------------------------\n" | tee -a /var/tmp/prechecks.log
		port_connectivity
		echo -e "----------------------------------------------------------------------------------\n" | tee -a /var/tmp/prechecks.log
		url_connectivity
		echo -e "----------------------------------------------------------------------------------\n" | tee -a /var/tmp/prechecks.log
		selinux_check
		echo -e "----------------------------------------------------------------------------------\n" | tee -a /var/tmp/prechecks.log
		echo -e "umask:\n" | tee -a /var/tmp/prechecks.log
		umask | tee -a /var/tmp/prechecks.log
		echo -e "----------------------------------------------------------------------------------\n" | tee -a /var/tmp/prechecks.log
		proxy_check
		echo -e "----------------------------------------------------------------------------------\n" | tee -a /var/tmp/prechecks.log
		firewall_check
		echo -e "----------------------------------------------------------------------------------\n" | tee -a /var/tmp/prechecks.log
		pipo_connectivity
		echo -e "----------------------------------------------------------------------------------\n" | tee -a /var/tmp/prechecks.log
		sysbench_check
		echo -e "----------------------------------------------------------------------------------" | tee -a /var/tmp/prechecks.log
		;;
	esac
