localrules: reads_multiqc

rule reads_fastqc:
    input: lambda wildcards: ancient(SAMPLES_DF.loc[wildcards.sample, 'File'])
    output:
          html="results/qc/fastqc/{sample}.html",
          zip="results/qc/fastqc/{sample}_fastqc.zip"
    log: "logs/qc/fastqc/{sample}.html.log"
    threads: config['fastqc']['threads']
    params: ""
    wrapper: "0.74.0/bio/fastqc"

rule reads_multiqc:
    input:
        expand(
            rules.reads_fastqc.output,
            sample=SAMPLES_DF.index
        )
    output:
        html="results/qc/multiqc/reads.html",
        html_data=directory("results/qc/multiqc/reads_data")
    log: "logs/qc/multiqc/reads.log"
    wrapper:
        "0.74.0/bio/multiqc"
