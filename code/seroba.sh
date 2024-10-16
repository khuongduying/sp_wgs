
# Setup docker_run
echo 'function docker_run() { docker run --rm=True -u $(id -u):$(id -g) -v $(pwd):/data "$@" ;}' >> ~/.bashrc


# Download database
docker_run staphb/seroba seroba getPneumocat PneumoCaT_dir


# Setup database
docker_run staphb/seroba seroba createDBs database/ 71

chmod 777 kmer_size.txt
chmod 777 -R /mnt/d12a/SP_WGS/data
# 
docker_run staphb/seroba seroba runSerotyping \
    #keep the intermediate files (assemblies, ariba reports)
    --noclean \
    database/ \
    data/sample1_1.fq.gz \
    data/sample1_2.fq.gz \
    noclean_test

# Loop for all samples
for sample in `ls -d data/raw/*/ | cut -d "/" -f 3`; do
    echo $sample;
    #ls data/raw/${sample}/${sample}_1.fastq;
    mkdir -p output/${sample};
    docker_run staphb/seroba seroba runSerotyping \
        database/ \
        data/raw/${sample}/${sample}_1.fastq \
        data/raw/${sample}/${sample}_2.fastq \
        out_${sample}
done

docker_run staphb/seroba seroba runSerotyping \
        database2/ \
        data/SRR28979521_1.fastq.gz \
        data/SRR28979521_2.fastq.gz \
        output


#fasterq-dump -e 24 --split-files */*.sra -O $dir

docker_run staphb/seroba seroba runSerotyping \
        database2/ \
        data/ERR10183298/ERR10183298_1.fastq \
        data/ERR10183298/ERR10183298_2.fastq \
        out_ERR10183298

for file in `ls */*.sra`; do 
    echo $file; 
    sample=`echo $file | cut -d "/" -f 1`; 
    echo $sample; 
    fasterq-dump -e 24 --split-files $file -O $sample;
done