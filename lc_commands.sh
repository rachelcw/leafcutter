"""
1. clustering leafcutter 
2. peer
3. covariate table
4. differential splicing
5. filtering by FDR
"""
#.junc file
echo filename.junc >> filename.txt ## the txt file contains the path of .junc file
#find the 712 junc file and put the full path of each file in txt file
for file in `ls /home/ls/rachelcw/projects/LEAFCUTTER/ccle/junctions/`
do
path='/home/ls/rachelcw/projects/LEAFCUTTER/ccle/junctions/'
fullpath=$path$file
echo $fullpath >> ccle_juncfiles_20230204.txt
done
# clustering the junc file
lc_py="/home/ls/rachelcw/projects/LEAFCUTTER/leafcutter/clustering/leafcutter_cluster.py"
junc_file="/home/ls/rachelcw/projects/LEAFCUTTER/ccle/ccle_juncfiles_20230204.txt"
output="ccle_20230204"

python $lc_py -j $junc_file -o $output -l 500000 

#differential splicing
/home/ls/rachelcw/projects/LEAFCUTTER/leafcutter/scripts/leafcutter_ds.R --num_threads 4 /home/ls/rachelcw/projects/LEAFCUTTER/712_lc_20221026/712_lc_20221026_perind_numers.counts.gz /home/ls/rachelcw/projects/LEAFCUTTER/groups_file.txt

## DOCKER ##
docker pull gcr.io/broad-cga-francois-gtex/leafcutter:latest
docker run -ti --rm gcr.io/broad-cga-francois-gtex/leafcutter:latest
#The “-ti” opens the docker image like you’re exploring a file system.
cd /opt
ls -l
And you find it at /opt/leafcutter/leafcutter/R/differential_splicing.R
Now you can run it using something like: 
garrettjenkinson/ubuntu18leafcutter:v0.2.9.1 /leafcutter/scripts/leafcutter_ds

#leafcutter_ds.R
docker run -v /home/ls/rachelcw/projects/LEAFCUTTER/:/data --rm garrettjenkinson/ubuntu18leafcutter:v0.2.9.1 Rscript /leafcutter/scripts/leafcutter_ds.R /data/lc_20230108/lc_20230108_perind_numers.counts.gz /data/DS/DS.five_percent/groups_file.analysis.20230108/groups_file_a5.txt -o /data/DS/ds.a5.20230205 -p 4 -e /data/gencode19_noChrPrefix_mitoMT.exonsForLeafcutter.gz --seed 613 
#ds_plots.pdf
docker run -v /home/ls/rachelcw/projects/LEAFCUTTER/:/data --rm garrettjenkinson/ubuntu18leafcutter:v0.2.9.1 Rscript /data/leafcutter/scripts/ds_plots.R /data/lc_20221211/lc_20221211_perind_numers.counts.gz /data/groups_file_peer.txt /data/DS/lc_ds_20221213_cluster_significance.txt -f 0.05 -o /data/DS/ds_plots.pdf
[connect your files with -v of course]
# gtf_to_exons
docker run -v /home/ls/rachelcw/projects/LEAFCUTTER/:/data --rm garrettjenkinson/ubuntu18leafcutter:v0.2.9.1 Rscript /data/leafcutter/scripts/gtf_to_exons.R  /data/gencode.v42


#gtf2leafcutter
./gtf2leafcutter.pl -o /home/ls/rachelcw/projects/BIO/gencode.v42 "/private1/private/resources/gencode.v42.annotation.gtf.gz"


#leafviz
docker run -v /home/ls/rachelcw/projects/LEAFCUTTER/:/data --rm garrettjenkinson/ubuntu18leafcutter:v0.2.9.1 Rscript /data/leafcutter/leafviz/prepare_results.R -m /data/groups_file_peer.txt -c leafcutter /data/lc_20221211/lc_20221211_perind_numers.counts.gz /data/DS/lc_ds_20221213_cluster_significance.txt /data/DS/lc_ds_20221213_effect_sizes.txt -o /data/DS/results.RData