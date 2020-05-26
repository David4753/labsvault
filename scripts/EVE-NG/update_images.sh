#!/bin/bash

BASE="/opt/unetlab/addons"
LIST="images.list"
IMAGESLIST="https://kutt.it/lv-images-list"
#

# download new images.list
rm -rf ${BASE}/${LIST}
megaurl=`curl -s $IMAGESLIST | cut -b 23-`
megadl --path=${BASE} $megaurl 

if ! test -f ${BASE}/${LIST} ; then
        # if download fail... exit...
        echo "${BASE}/${LIST} not exist" 
        exit 1
fi


while IFS= read -r line
do
        DIR=`echo $line | awk -F\| '{ print $1 }'`
        FILE=`echo $line | awk -F\| '{ print $2 }'`
        SHA1=`echo $line | awk -F\| '{ print $3 }'`
        TINYURL=`echo $line | awk -F\| '{ print $4 }'`
        if ! test -z ${TINYURL} ; then        
                URL=`curl -s $TINYURL | cut -b 23-`
                FileLocal=${BASE}${DIR}${FILE}
                if test -d ${BASE}${DIR} ; then
                        if test -f ${FileLocal} ; then
                                sha1=`sha1sum ${FileLocal} | awk '{ print $1}' `
                                if [ $SHA1 != $sha1 ]; then
                                        rm -rf ${FileLocal}
                                        echo "Downloading ${FILE} in ${BASE}${DIR}..." 
                                        mkdir -p ${BASE}${DIR} && megadl --path=${FileLocal} ${URL} 
        	                        else
                                        echo "${FileLocal} is update" 
                                fi
                        else
                                echo "Downloading ${FILE} in ${BASE}${DIR}..." 
                                mkdir -p ${BASE}${DIR} && megadl --path=${FileLocal} ${URL} 
                        fi
                else
                        echo "Downloading ${FILE} in ${BASE}${DIR}..." 
                        mkdir -p ${BASE}${DIR} && megadl --path=${FileLocal} ${URL} 
                fi
        fi
done < <( cat ${BASE}/${LIST} ) 

/opt/unetlab/wrappers/unl_wrapper -a fixpermissions 
