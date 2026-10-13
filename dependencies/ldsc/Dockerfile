# Use an appropriate base image
FROM continuumio/miniconda3

# Add conda to PATH
ENV PATH=/opt/conda/bin:$PATH

# Create application directory
RUN git clone https://github.com/CBIIT/ldsc.git && \
    cd ldsc && \
    git checkout 9c78156 && \
    mkdir ldscores

# Create the conda environment
RUN conda env create -f /ldsc/environment3.yml

# Make sure that python from the conda environment is used when the image is run
ENTRYPOINT ["conda", "run", "--no-capture-output", "-n", "ldsc"]
