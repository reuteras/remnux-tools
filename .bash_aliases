alias docker-remnux-v8='sudo docker run --rm -it -v ~/cases/docker/v8:/home/nonroot/files remnux/v8 bash'
alias docker-remnux-radare2="sudo docker run --rm -it -v ~/cases/docker/radare2:/home/nonroot/workdir remnux/radare2 bash"
alias docker-remnux-pescanner="sudo docker run --rm -it -v ~/cases/docker/pescanner:/home/nonroot/workdir remnux/pescanner bash"
alias docker-remnux-jsdetox="sudo docker run --rm -p 3000:3000 remnux/jsdetox"
alias docker-remnux-thug="sudo docker run --rm -it -v ~/cases/docker/thug:/home/thug/logs remnux/thug bash"
alias docker-remnux-mastiff="sudo docker run --rm -it -v ~/cases/docker/mastiff:/home/nonroot/workdir remnux/mastiff"
alias docker-remnux-viper-web="sudo docker run --rm -p 9090:9090 -v ~/cases/docker/viper:/home/nonroot/workdir remnux/viper"
alias docker-remnux-viper-cmd="sudo docker run --rm -it -v ~/cases/docker/viper:/home/nonroot/workdir remnux/viper bash"
alias jdeserialize="java -jar ~/remnux-tools/lib/jdeserialize-1.2.jar -noclasses"
alias private="/usr/bin/curl http://icanhazip.com"
alias zerodisk="dd if=/dev/zero of=zero; sync; rm -f zero"
