version 1.0
# -------------------------------------------------------------------------------------------------
# Package Name: https://software.broadinstitute.org/gatk/
# Task Summary: Filter variant calls based on INFO and FORMAT annotations
# Tool Name: GATK VariantFiltration
# Documentation: https://software.broadinstitute.org/gatk/documentation/tooldocs/3.8-0/org_broadinstitute_gatk_tools_walkers_filters_VariantFiltration.php
# Example: https://software.broadinstitute.org/wdl/documentation/article?id=7615
# -------------------------------------------------------------------------------------------------


task VariantFiltration {
  input {
    File ? java
    File ? gatk
    File reference
    File reference_idx
    File reference_dict

    File input_file
    File input_idx_file

    Int clusterWindowSize = 10
    String filterExpression = ""
    String filterName = ""
    String ? userString

    Array[String] modules = []
    Float memory = 12
    Int cpu = 1

    String output_filename = basename(input_file) + ".filtered.vcf.gz"
    String output_idx_filename = basename(input_file) + ".filtered.vcf.gz.tbi"
  }

  Int jvm_memory = round(memory)

  command {
    set -Eeuxo pipefail;

    for MODULE in ~{sep=' ' modules}; do
      module load $MODULE
    done;

    ~{default="java" java} \
      -Xmx~{jvm_memory}g \
      -jar ~{default="gatk" gatk} \
      -T VariantFiltration \
      ~{userString} \
      -R ~{reference} \
      --variant ~{input_file} \
      --clusterWindowSize ~{clusterWindowSize} \
      ~{"--filterExpression " + filterExpression} \
      ~{"--filterName " + filterName} \
      -o ~{output_filename};
  }

  output {
    File vcf_file = "~{output_filename}"
    File vcf_idx_file = "~{output_idx_filename}"
  }

  runtime {
    memory: memory * 1.5 + " GB"
    cpu: cpu
  }

  parameter_meta {
    java: "Path to Java."
    gatk: "GATK jar file."
    reference: "Reference sequence file."
    reference_idx: "Reference sequence index (.fai)."
    reference_dict: "Reference sequence dict (.dict)."
    input_file: "Two or more VCF files."
    input_idx_file: "VCF index files (.tbi)."
    clusterWindowSize: "The window size (in bases) in which to evaluate clustered SNPs."
    filterExpression: "One or more expression used with INFO fields to filter."
    filterName: "Names to use for the list of filters."
    userString: "An optional parameter which allows the user to specify additions to the command line at run time."
    memory: "GB of RAM to use at runtime."
    cpu: "Number of CPUs to use at runtime."
  }

  meta {
    author: "Michael A. Gonzalez"
    email: "GonzalezMA@email.chop.edu"
    gatk_version: "3.8"
    version: "0.1.0"
  }
}
