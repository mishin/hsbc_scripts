
README

## diff file structure

1. directory

		cd /pub/git/hsbc_scripts/file_struct_diff/ongoing/hubstruct

1. create 1115.changed

		mkdir 1115.changed

1. upload file structure csv to /tmp/ORACLEhub5.csv
1. split it

		$ cd  1115.changed
		$ ../../../day1/split.sh  /tmp/ORACLEhub5.csv

1. convert to dos

		$ cd hub5
		$ dos2unix *

1. diff

		$ cd  /home/yyt/hsbc_script/file_struct_diff/ongoing/hubstruct/1115.changed
		$ mkdir before
		$ ../../../day1/diff.sh hub nocdc ./before ./hub5

## create day1 jobs

1. put hub5.job/* to day1/tb/
1. cd /pub/git/hsbc_scripts/batch_jobs/day1/bin

		./runme.sh 
		usage: ./runme.sh [hub|tts] [day1|date|date1|date2]

1. merge all jobs to one file (output file is /tmp/YYYYMMDD.dsx)

		/pub/git/hsbc_scripts/batch_jobs/day1/many2one.sh


