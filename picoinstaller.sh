#!/bin/bash
set -e

function compose_check() {
	if [ -x "$(command -v docker-compose)" ]; then
		version=$(docker-compose --version |cut -d ' ' -f3 | cut -d ',' -f1)
		if [[ "$version" != "1.23.1" ]]; then
			echo -n "[-] Finding docker-compose installation - found incompatible version"
			echo -e "... \e[0;31m[ERROR] \e[0m\n"
			echo -e "[-] Updating docker-compose\n"
			sudo curl -L "https://github.com/docker/compose/releases/download/1.23.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose &>> /DNIF/install.log
			sudo chmod +x /usr/local/bin/docker-compose &>> /DNIF/install.log
			echo -e "[-] Installing docker-compose - ... \e[1;32m[DONE] \e[0m\n"
		else
			echo -e "[-] docker-compose up-to-date\n"
			echo -e "[-] Installing docker-compose - ... \e[1;32m[DONE] \e[0m\n"
		fi
	else
		echo -e "[-] Finding docker-compose installation - ... \e[1;31m[NEGATIVE] \e[0m\n"
		echo -e "[-] Installing docker-compose\n"
		sudo curl -L "https://github.com/docker/compose/releases/download/1.23.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose &>> /DNIF/install.log
		sudo chmod +x /usr/local/bin/docker-compose&>> /DNIF/install.log
        echo -e "[-] Installing docker-compose - ... \e[1;32m[DONE] \e[0m\n"
	fi
}

function compose_check_centos() {
	if [ -x "$(command -v docker-compose)" ]; then
		version=$(docker-compose --version |cut -d ' ' -f3 | cut -d ',' -f1)
		if [[ "$version" != "1.23.1" ]]; then
			echo -n "[-] Finding docker-compose installation - found incompatible version"
			echo -e "... \e[0;31m[ERROR] \e[0m\n"
			echo -e "[-] Updating docker-compose\n"
			sudo curl -k -L "https://github.com/docker/compose/releases/download/1.23.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose &>> /DNIF/install.log
			sudo chmod +x /usr/local/bin/docker-compose &>> /DNIF/install.log
			echo -e "[-] Installing docker-compose - ... \e[1;32m[DONE] \e[0m\n"
		else
			echo -e "[-] docker-compose up-to-date\n"
			echo -e "[-] Installing docker-compose - ... \e[1;32m[DONE] \e[0m\n"
		fi
	else
		echo -e "[-] Finding docker-compose installation - ... \e[1;31m[NEGATIVE] \e[0m\n"
		echo -e "[-] Installing docker-compose\n"
		sudo curl -k -L "https://github.com/docker/compose/releases/download/1.23.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose &>> /DNIF/install.log
		sudo chmod +x /usr/local/bin/docker-compose &>> /DNIF/install.log
		filedc="/usr/bin/docker-compose"
		if [ ! -f "$filedc " ]; then
			sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose &>> /DNIF/install.log
		fi
    echo -e "[-] Installing docker-compose - ... \e[1;32m[DONE] \e[0m\n"
	fi

}

function docker_check() {
	echo -e "[-] Finding docker installation\n"
	if [ -x "$(command -v docker)" ]; then
		currentver="$(docker --version |cut -d ' ' -f3 | cut -d ',' -f1)"
		requiredver="20.10.3"
		if [ "$(printf '%s\n' "$requiredver" "$currentver" | sort -V | head -n1)" = "$requiredver" ]; then
			echo -e "[-] docker up-to-date\n"
			echo -e "[-] Finding docker installation ... \e[1;32m[DONE] \e[0m\n"
		else
			echo -n "[-] Finding docker installation - found incompatible version"
			echo -e "... \e[0;31m[ERROR] \e[0m\n"
			echo -e "[-] Uninstalling docker\n"
			sudo apt-get remove docker docker-engine docker.io containerd runc&>> /DNIF/install.log
			docker_install
		fi
	else
		echo -e "[-] Finding docker installation - ... \e[1;31m[NEGATIVE] \e[0m\n"
		echo -e "[-] Installing docker\n"
		docker_install
		echo -e "[-] Finding docker installation - ... \e[1;32m[DONE] \e[0m\n"
	fi

}

function docker_check_centos() {
	echo -e "[-] Finding docker installation\n"
	if [ -x "$(command -v docker)" ]; then
		currentver="$(docker --version |cut -d ' ' -f3 | cut -d ',' -f1)"
		requiredver="20.10.3"
		if [ "$(printf '%s\n' "$requiredver" "$currentver" | sort -V | head -n1)" = "$requiredver" ]; then
			echo -e "[-] docker up-to-date\n"
			echo -e "[-] Finding docker installation ... \e[1;32m[DONE] \e[0m\n"
		else
			echo -n "[-] Finding docker installation - found incompatible version"
			echo -e "... \e[0;31m[ERROR] \e[0m\n"
			echo -e "[-] Uninstalling docker\n"
			sudo yum remove docker \
			docker-client \
			docker-client-latest \
			docker-common \
			docker-latest \
			docker-latest-logrotate \
			docker-logrotate \
			docker-engine&>> /DNIF/install.log
			docker_install_centos
		fi
	else
        	echo -e "[-] Finding docker installation - ... \e[1;31m[NEGATIVE] \e[0m\n"
        	echo -e "[-] Installing docker\n"
        	docker_install_centos
        	echo -e "[-] Finding docker installation - ... \e[1;32m[DONE] \e[0m\n"
	fi

}

function docker_install() {
	sudo apt-get -y update&>> /DNIF/install.log
	echo -e "[-] Setting up docker-ce repositories\n"
	sudo apt-get -y install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common&>> /DNIF/install.log
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -&>> /DNIF/install.log
	sudo apt-key fingerprint 0EBFCD88&>> /DNIF/install.log
	sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"&>> /DNIF/install.log
	sudo apt-get -y update&>> /DNIF/install.log
	echo -e "[-] Installing docker-ce\n"
	sudo apt-get -y install docker-ce docker-ce-cli containerd.io&>> /DNIF/install.log
}

function docker_install_centos() {
	sudo yum install -y yum-utils&>> /DNIF/install.log
	echo -e "[-] Setting up docker-ce repositories\n"
	sudo yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo&>> /DNIF/install.log
	echo -e "[centos-extras]
	name=Centos extras - $"basearch"
	baseurl=http://mirror.centos.org/centos/7/extras/x86_64
	enabled=1
	gpgcheck=1
	gpgkey=http://centos.org/keys/RPM-GPG-KEY-CentOS-7">>/etc/yum.repos.d/docker-ce.repo

	file1="/usr/bin/slirp4netns"
	if [ ! -f "$file1 " ]; then
		yum install -y slirp4netns&>> /DNIF/install.log
	fi
	file2="/usr/bin/fuse-overlayfs"
	if [ ! -f "$file2 " ]; then
		yum install -y fuse-overlayfs&>> /DNIF/install.log
	fi
	file3="/usr/bin/container-selinux"
	if [ ! -f "$file3 " ]; then
		yum install -y container-selinux&>> /DNIF/install.log
	fi
	sudo yum install -y docker-ce docker-ce-cli containerd.io&>> /DNIF/install.log
	sudo systemctl start docker&>> /DNIF/install.log
	sudo systemctl enable docker.service&>> /DNIF/install.log
}

function docker_image () {
	echo -e "\n[-] Checking Docker Image for PICO $tag\n"
	pcimage=$(echo "$(docker images | grep 'dnif/pico' | grep "$tag")")
	if [ -n "$pcimage" ]; then
		echo -e "[-] Docker Image pico:$tag already exists."
		echo -e "$pcimage"
	else
		echo -e "[-] Docker Image pico:$tag does not exist. Pulling the image..."
		docker pull docker.io/dnif/pico:$tag
		echo -e "[-] Image pull completed..!"
		echo -e "$pcimage"
	fi
}

function podman_image () {
	echo -e "\n[-] Checking Docker Image for PICO $tag\n"
	pcimage=$(echo "$(podman images | grep 'dnif/pico' | grep "$tag")")
	if [ -n "$pcimage" ]; then
		echo -e "[-] Docker Image pico:$tag already exists."
		echo -e "$pcimage"
	else
		echo -e "[-] Docker Image pico:$tag does not exist. Pulling the image..."
		podman pull docker.io/dnif/pico:$tag
		echo -e "[-] Image pull completed..!"
		echo -e "$pcimage"
	fi
}

function sysctl_check() {
	count=$(sysctl -n vm.max_map_count)
	if [ "$count" = "262144" ]; then
		echo -e "[-] Fine tuning the operating system\n"
		#ufw -f reset&>> /DNIF/install.log
	else
		echo -e "#memory & file settings
		fs.file-max=1000000
		vm.overcommit_memory=1
		vm.max_map_count=262144
		#n/w receive buffer
		net.core.rmem_default=33554432
		net.core.rmem_max=33554432" >>/etc/sysctl.conf
		sysctl -p&>> /DNIF/install.log
		#ufw -f reset&>> /DNIF/install.log
	fi
}

function set_proxy() {
	echo "HTTP_PROXY="\"$ProxyUrl"\"" >> /etc/environment
	echo "HTTPS_PROXY="\"$ProxyUrl"\"" >> /etc/environment
	echo "https_proxy="\"$ProxyUrl"\"" >> /etc/environment
	echo "http_proxy="\"$ProxyUrl"\"" >> /etc/environment
	export HTTP_PROXY=$ProxyUrl 
	export HTTPS_PROXY=$ProxyUrl 
	export https_proxy=$ProxyUrl 
	export http_proxy=$ProxyUrl
}

#echo -e "----------------------------------------------------------------------------------------------------------------------------------"


function podman_compose_check() {
	file="/usr/bin/podman-compose"
	if [ -f "$file" ]; then
		version=$(podman-compose version | grep 'podman version' | awk '{print $3}' | cut -d "-" -f1)
		if [[ "$version" != "1.0.4" ]]; then
			echo -n "[-] Finding podman-compose installation - found incompatible version"
			echo -e "... \e[0;31m[ERROR] \e[0m\n"
			echo -e "[-] Updating podman-compose\n"
			rm -rf /usr/bin/podman-compose&>> /DNIF/install.log
            pip3 install --upgrade setuptools&>> /DNIF/install.log
			pip3 install https://github.com/containers/podman-compose/archive/devel.tar.gz&>> /DNIF/install.log
			sudo ln -s /usr/local/bin/podman-compose /usr/bin/podman-compose&>> /DNIF/install.log
			echo -e "[-] Installing podman-compose - ... \e[1;32m[DONE] \e[0m\n"
		else
			echo -e "[-] podman-compose up-to-date\n"
			echo -e "[-] Installing podman-compose - ... \e[1;32m[DONE] \e[0m\n"
		fi
	else
		echo -e "[-] Finding podman-compose installation - ... \e[1;31m[NEGATIVE] \e[0m\n"
		echo -e "[-] Installing podman-compose\n"
		pip3 install --upgrade setuptools&>> /DNIF/install.log
		pip3 install https://github.com/containers/podman-compose/archive/devel.tar.gz&>> /DNIF/install.log
		sudo ln -s /usr/local/bin/podman-compose /usr/bin/podman-compose&>> /DNIF/install.log
        echo -e "[-] Installing podman-compose - ... \e[1;32m[DONE] \e[0m\n"
	fi
}

function podman_check() {
	echo -e "[-] Finding podman installation\n"
	if [ -x "$(command -v podman)" ]; then
		currentver="$(podman --version|cut -d ' ' -f3)"
		requiredver="2.2.1"
		if [ "$(printf '%s\n' "$requiredver" "$currentver" | sort -V | head -n1)" = "$requiredver" ]; then
			echo -e "[-] podman up-to-date\n"
			echo -e "[-] Finding podman installation ...\e[1;32m[DONE] \e[0m\n"
		else
			echo -n "[-] Finding podman installation - found incompatible version"
			echo -e "... \e[0;31m[ERROR] \e[0m\n"
			echo -e "[-] Uninstalling podman\n"
			podman_install
		fi
	else
		echo -e "[-] Finding podman installation - ... \e[1;31m[NEGATIVE] \e[0m\n"
		echo -e "[-] Installing podman\n"
		podman_install
		echo -e "[-] Finding podman installation - ... \e[1;32m[DONE] \e[0m\n"
	fi
}

function podman_install() {
	sudo dnf install -y @container-tools&>> /DNIF/install.log
}

function python_install() {
	echo -e "[-] Checking for python3\n"
	if [ -x "$(command -v python3)" ]; then
		echo -e "[-] $(python3 --version) version is present\n"
	else
		echo -e "[-] Installing python3\n"
		sudo dnf update -y &>> /DNIF/install.log
		sudo dnf install -y python3 &>> /DNIF/install.log
		echo -e "\n[-] Installed $(python3 --version) version\n"
	fi
	echo -e "[-] Checking for pip3\n"
	if [ -x "$(command -v pip3)" ]; then
		echo -e "[-] $(pip3 --version) version is present\n"
	else
		echo -e "[-] Installing pip3\n"
		#sudo dnf update -y &>> /DNIF/install.log
		sudo dnf install -y python3-pip &>> /DNIF/install.log
		echo -e "[-] Installed $(pip3 --version) version\n"
	fi
}

tag="v9.4.1"

if [ -r /etc/os-release ]; then
	os="$(. /etc/os-release && echo "$ID")"
fi

case "${os}" in
	ubuntu|centos)
		if [[ $EUID -ne 0 ]]; then
			echo -e "This script must be run as root ... \e[1;31m[ERROR] \e[0m\n"
			exit 1
		else

			ARCH=$(uname -m)
			if [[ $os == "ubuntu" ]]; then
				VER=$(lsb_release -rs)
				release=$(lsb_release -ds)
			elif [[ $os == "centos" ]]; then
				VER=$(cat /etc/redhat-release | sed s/.*release\ // | sed s/\ .*//)
				release="$(. /etc/os-release && echo "$PRETTY_NAME")"
			fi
			mkdir -p /DNIF
			echo -e "\nDNIF Installer for $tag\n"
			echo -e "for more information and code visit https://github.com/dnif/installer\n"

			echo -e "++ Checking operating system for compatibility...\n"

			echo -n "Operating system compatibility"
			sleep 2
			if { [[ "$VER" = "20.04" ]] || [[ "$VER" = "22.04" ]] || [[ "$VER" = "7.9.2009" ]]; } && [[ "$ARCH" = "x86_64" ]]; then
				echo -e " ... \e[1;32m[OK] \e[0m"
				echo -n "Architecture compatibility "
				echo -e " ... \e[1;32m[OK] \e[0m\n"
				echo -e "** found $release $ARCH\n"
				echo -e "[-] Checking operating system for compatibility - ... \e[1;32m[DONE] \e[0m\n"
				echo -e "** Please report issues to https://github.com/dnif/installer/issues"
				echo -e "** for more information visit https://docs.dnif.it/v9/docs/high-level-dnif-architecture\n"
				echo -e "-----------------------------------------------------------------------------------------"
				echo -e "[-] Installing the PICO \n"
				if [[ "$1" == "proxy" ]]; then
					ProxyUrl=""
					while [[ ! "$ProxyUrl" ]]; do
						echo -e "ENTER Proxy url: \c"
						read -r ProxyUrl
					done
					set_proxy $ProxyUrl
				fi
				if [[ $os == "ubuntu" ]]; then
					docker_check
					compose_check
					sysctl_check
					ufw -f reset&>> /DNIF/install.log
				elif [[ $os == "centos" ]]; then
					docker_check_centos
					compose_check_centos
					sysctl_check
					setenforce 0 &>> /DNIF/install.log || true
				fi
				if [[ $ProxyUrl ]]; then
					mkdir -p /etc/systemd/system/docker.service.d
					echo -e "[Service]
					Environment=\"HTTPS_PROXY=$ProxyUrl\"">/etc/systemd/system/docker.service.d/http-proxy.conf

					sudo systemctl daemon-reload
					sudo systemctl restart docker
				fi

				docker_image

				COREIP=""
				while [[ ! $COREIP =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; do
					echo -e "ENTER CORE IP: \c"
					read -r COREIP
				done
				cd /
				sudo mkdir -p /DNIF
				sudo mkdir -p /DNIF/PICO
				sudo echo -e "version: "\'2.1\'"
services:
 pico:
  image: dnif/pico:$tag
  network_mode: "\'host\'"
  restart: unless-stopped
  cap_add:
   - NET_ADMIN
  environment:
   - "\'CORE_IP="$COREIP"\'"
   - "\'PROXY="$ProxyUrl"\'"
  volumes:
   - /DNIF/PICO:/dnif
   - /DNIF/backup/pc:/backup
  container_name: pico-v9">/DNIF/PICO/docker-compose.yaml
				cd /DNIF/PICO || exit
				IP=$(ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1  -d'/')
				echo -e "[-] Starting container...\n "
				docker-compose up -d
				echo -e "[-] Starting container ... \e[1;32m[DONE] \e[0m\n"
				docker ps
				echo -e "** Congratulations you have successfully installed the PICO\n"
				echo -e "**   Activate the PICO ($IP) from the components page\n"				
			else
				echo -e "\e[0;31m[ERROR] \e[0m Operating system is incompatible"
			fi
		fi

		;;
	rhel)
		if [[ $EUID -ne 0 ]]; then
			echo -e "This script must be run as root ... \e[1;31m[ERROR] \e[0m\n"
			exit 1
		else
			ARCH=$(uname -m)
			VER=$(cat /etc/redhat-release | sed s/.*release\ // | sed s/\ .*//)
			release="$(. /etc/os-release && echo "$PRETTY_NAME")"

			mkdir -p /DNIF
			echo -e "\nDNIF Installer for $tag\n"
			echo -e "for more information and code visit https://github.com/dnif/installer\n"

			echo -e "++ Checking operating system for compatibility...\n"

			echo -n "Operating system compatibility "
			sleep 2
			if [[ "$VER" = "8.5" ]] && [[ "$ARCH" = "x86_64" ]];  then # replace 8.5 by the number of release you want
				echo -e " ... \e[1;32m[OK] \e[0m"
				echo -n "Architecture compatibility "
				echo -e " ... \e[1;32m[OK] \e[0m\n"
				echo -e "** found $release $ARCH\n"
				echo -e "[-] Checking operating system for compatibility - ... \e[1;32m[DONE] \e[0m\n"
				echo -e "** Please report issues to https://github.com/dnif/installer/issues"
				echo -e "** for more information visit https://docs.dnif.it/v9/docs/high-level-dnif-architecture\n"
				echo -e "[-] Installing the PICO \n"
				if [[ "$1" == "proxy" ]]; then
					ProxyUrl=""
					while [[ ! "$ProxyUrl" ]]; do
						echo -e "ENTER Proxy url: \c"
						read -r ProxyUrl
					done
					set_proxy $ProxyUrl
				fi
                python_install
				podman_check
				podman_compose_check
				sysctl_check
				setenforce 0&>> /DNIF/install.log || true
				mkdir -p /DNIF/PICO&>> /DNIF/install.log
				file="/usr/bin/wget"
				if [ ! -f "$file " ]; then
					dnf install -y wget&>> /DNIF/install.log
					dnf install -y zip&>> /DNIF/install.log
				fi

				
				mkdir -p /DNIF/backup/pc&>> /DNIF/install.log
				if [[ $ProxyUrl ]]; then
					mkdir -p /etc/systemd/system/docker.service.d
					echo -e "[Service]
					Environment=\"HTTPS_PROXY=$ProxyUrl\"">/etc/systemd/system/docker.service.d/http-proxy.conf

					sudo systemctl daemon-reload
					sudo systemctl restart podman
				fi
				
				podman_image

				COREIP=""
				while [[ ! $COREIP =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; do
					echo -e "ENTER CORE IP: \c"
					read -r COREIP
				done
				sudo echo -e "version: "\'2.1\'"
services:
 pico:
  image: docker.io/dnif/pico:$tag
  network_mode: "\'host\'"
  restart: unless-stopped
  cap_add:
   - NET_ADMIN
  environment:
   - "\'PROXY="$ProxyUrl"\'"
   - "\'CORE_IP="$COREIP"\'"
  volumes:
   - /DNIF/PICO:/dnif
   - /DNIF/backup/pc:/backup
  container_name: pico-v9">/DNIF/PICO/podman-compose.yaml

				echo -e "[-] Starting container... \n"
				cd /DNIF/PICO
                IP=$(ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1  -d'/')
				podman-compose up -d
                echo -e "[-] Starting container ... \e[1;32m[DONE] \e[0m\n"
				podman ps
				echo -e "** Congratulations you have successfully installed the PICO\n"
				echo -e "**   Activate the PICO ($IP) from the components page\n"
			else
				echo -e "\n\e[0;31m[ERROR] \e[0m Operating system is incompatible"
			fi
		fi
		;;
	esac
