nextflow.enable.dsl = 2

params.results_dir = "results" // where to write the results
params.n = 300 // sample size to subset each population to

workflow {
    samples = file("data/vcf/integrated_call_samples_v3.20130502.ALL.panel")
    relatives = file("data/vcf/20140625_related_individuals.txt")

    pops = [
        tuple("AFR", "AFR"),
        tuple("AMR", "AMR"),
        tuple("EAS", "EAS"),
        tuple("EUR", "EUR"),
        tuple("SAS", "SAS"),
    ]

    pop_c = channel.from(pops)
    sample_c = channel.of(samples)
    relative_c = channel.of(relatives)
    n_c = channel.of(params.n)
    
    pop_sample_lists_c = pop_c
        | combine(sample_c)
        | combine(relative_c)
        | combine(n_c)
        | get_sample_lists

    vcf_dir = file("data/vcf/")
    map_dir = file("data/map/")
    reg_dir = file("data/hm3/")

    chr_c = channel.from(1..22)

    chr_vcf_c = chr_c
        | map { chr -> [chr, 
                        "${vcf_dir}/ALL.chr${chr}.phase3_shapeit2_mvncall_integrated_v5b.20130502.genotypes.vcf.gz",
                        "${vcf_dir}/ALL.chr${chr}.phase3_shapeit2_mvncall_integrated_v5b.20130502.genotypes.vcf.gz.tbi",
                        "${reg_dir}/chr${chr}.rsid.coordinates.hg19.regions",
                        "${reg_dir}/chr${chr}.rsid.coordinates.hg19.tsv"] }
    
    bfile_c = pop_sample_lists_c
        | combine(chr_vcf_c)
        | subset_vcfs
        | map { t -> [t[0], t[1], t[2], "${map_dir}/genetic_map_chr${t[1]}_combined_b37.txt"] }
        | vcf_2_bfile_plus_map

    get_ldscores(bfile_c)
}

process get_sample_lists {
    publishDir "${params.results_dir}/sample_lists", mode: 'copy'

    input:
    tuple val(pop), val(pop_regex), path(sample_list), path(relative_list), val(N)

    output:
    tuple val({pop}), path("*samples.tsv")

    script:
    """
    egrep -e "[A-Z]{2}[0-9]{5}" -o ${relative_list} > exclude
    egrep "${pop_regex}" ${sample_list} | cut -f1 > all_samples
    egrep -v -f exclude all_samples | gshuf | head -n${N} > ${pop}.samples.tsv
    """
}

process subset_vcfs {
    // publishDir "${params.results_dir}/per_pop_vcfs", mode: 'copy'

    input:
    tuple val(pop), path(pop_sample_list), val(chr), path(vcf), path(tbi), path(regions), path(annotations)

    output:
    tuple val({pop}), val({chr}), path("${pop}.${chr}.vcf.gz")

    script:
    """
    bgzip ${annotations}
    tabix -s1 -b2 -e2 -S1 ${annotations}.gz
    bcftools view \
        --samples-file ${pop_sample_list} \
        --regions-file ${regions} \
        -v snps \
        ${vcf} |\
    bcftools annotate \
        --annotations ${annotations}.gz \
        --columns CHROM,POS,ID \
        --output-type z > ${pop}.${chr}.vcf.gz
    tabix ${pop}.${chr}.vcf.gz
    """

}

process vcf_2_bfile_plus_map {
    // publishDir "${params.results_dir}/per_pop_bfiles", mode: 'copy'

    input:
    tuple val(pop), val(chr), path(vcf), path(map)

    output:
    tuple val({pop}), val({chr}), path("${pop}.${chr}*")

    script:
    """
    plink \
        --vcf ${vcf} \
        --double-id \
        --cm-map ${map} ${chr} \
        --make-bed \
        --out ${pop}.${chr}
    """

}

process get_ldscores {
    publishDir "${params.results_dir}/ldscores/${pop}", mode: "copy"

    input:
    tuple val(pop), val(chr), path(bfiles)

    output:
    path("${chr}*")

    script:
    """
    python /ldsc/ldsc.py \
        --bfile ${pop}.${chr} \
        --l2 \
        --ld-wind-cm 1 \
        --out ${chr}
    """
}
