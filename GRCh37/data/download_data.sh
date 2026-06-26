# Download phased genotype data + sample relatedness info + sample population information from the 1000 Genomes project

mkdir vcf/

seq 1 22 |\
    parallel -j8 wget -P vcf/ https://ftp.1000genomes.ebi.ac.uk/vol1/ftp/release/20130502/ALL.chr{}.phase3_shapeit2_mvncall_integrated_v5b.20130502.genotypes.vcf.gz

seq 1 22 |\
    parallel -j8 wget -P vcf/ https://ftp.1000genomes.ebi.ac.uk/vol1/ftp/release/20130502/ALL.chr{}.phase3_shapeit2_mvncall_integrated_v5b.20130502.genotypes.vcf.gz.tbi

wget -P vcf/ https://ftp.1000genomes.ebi.ac.uk/vol1/ftp/release/20130502/20140625_related_individuals.txt
wget -P vcf/ https://ftp.1000genomes.ebi.ac.uk/vol1/ftp/release/20130502/integrated_call_samples_v3.20130502.ALL.panel


# # and download genetic maps (which were made from the above data - see https://mathgen.stats.ox.ac.uk/impute/1000GP%20Phase%203%20haplotypes%206%20October%202014.html)

# wget https://mathgen.stats.ox.ac.uk/impute/1000GP_Phase3.tgz && \
#     tar -xf 1000GP_Phase3.tgz && \
#     rm 1000GP_Phase3.tgz && \
#     mv 1000GP_Phase3 map && \
#     rm map/1000GP* # don't need these files and they're big
