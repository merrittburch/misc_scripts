#!/bin/bash

# ---------------------------------------------------------------
# Author.... Merritt Khaipho-Burch
# Contact... mbb262@cornell.edu
# Date...... 2021-06-09 
#
# Description 
#   - Calculate a genomic relationship matrix for NAM and 282
#   - Use PHG imputed SNPs for:
#   - 1) genome wide SNPs 2) SNPs only within specific intervals
# ---------------------------------------------------------------
cp -R /home/mbb262/bioinformatics/tassel-5-standalone /workdir/mbb262

# --------------------
#  NAM SNPs and GRM
# --------------------

# Split results into different chromosomes
bgzip -c /workdir/ag2484/NAM_phg_snps.vcf > /workdir/mbb262/NAM_phg_snps.vcf.gz
tabix -p vcf /workdir/mbb262/NAM_phg_snps.vcf.gz

# loop extract's each chromosome's info
tabix myvcf.vcf.gz chr1 > chr1.vcf


# Filter data using tassel using MAF then randomly subset 10M sites genome wide
/home/mbb262/bioinformatics/tassel-5-standalone/run_pipeline.pl \
    -debug /workdir/mbb262/debug_calculate_grm.log \
    -Xmx500g \
    -maxThreads 60 \
    -importGuess /workdir/ag2484/NAM_phg_snps.vcf -noDepth \
    -filterAlign \
    -filterAlignMinFreq 0.01 \
    -filterAlignMaxFreq 0.99 \
    -subsetSites 10000000 \
    -step \
    -export /workdir/mbb262/filtered_NAM_phg_snps.vcf.gz \
    -exportType VCF


# calculate kinship genome wide using a subsetted vcf
/home/mbb262/bioinformatics/tassel-5-standalone/run_pipeline.pl \
    -debug /workdir/mbb262/debug_calculate_grm_kinship.log \
    -Xmx500g \
    -maxThreads 60 \
    -importGuess /workdir/mbb262/filtered_NAM_phg_snps.vcf.gz -noDepth \
    -KinshipPlugin \
    -method Centered_IBS \
    -endPlugin \
    -export /workdir/mbb262/kinship_filtered_NAM_phg_snps.vcf


# --------------------
#  282 SNPs and GRM
# --------------------

# Filter data using tassel using MAF then randomly subset 10M sites genome wide
/home/mbb262/bioinformatics/tassel-5-standalone/run_pipeline.pl \
    -debug /workdir/mbb262/goodman_downsample_debug.log \
    -Xmx500g \
    -maxThreads 60 \
    -importGuess /workdir/ag2484/goodman_phg_snps.txt.vcf -noDepth \
    -filterAlign \
    -filterAlignMinFreq 0.01 \
    -filterAlignMaxFreq 0.99 \
    -export /workdir/mbb262/filtered_goodman_phg_snps.vcf.gz \
    -exportType VCF

# Randomly subsample snps (might need to unzip)
gunzip filtered_goodman_phg_snps.vcf.gz
shuf -n 15000 filtered_goodman_phg_snps.vcf > subsampled_10M_filtered_goodman_phg_snps.vcf


# calculate kinship genome wide using a subsetted vcf
/home/mbb262/bioinformatics/tassel-5-standalone/run_pipeline.pl \
    -debug /workdir/mbb262/goodman_calc_grm_debug.log \
    -Xmx500g \
    -maxThreads 60 \
    -importGuess /workdir/mbb262/subsampled_10M_filtered_goodman_phg_snps.vcf -noDepth \
    -KinshipPlugin \
    -method Centered_IBS \
    -endPlugin \
    -export /workdir/mbb262/kinship_filtered_goodman_phg_snps.vcf

# Randomly subsample snps
shuf -n 15000 snps_file.vcf



# -----------------------------------------
#  NAM SNPs and GRM --> HARE regions only
# -----------------------------------------

# bed file from HARE genes in v4, filtering SNPs within these intervals


# -----------------------------------------
#  282 SNPs and GRM --> HARE regions only
# -----------------------------------------
