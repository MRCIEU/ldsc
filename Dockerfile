FROM python:3.13

RUN apt -y update

COPY GRCh37/results/ldscores/ /ldscores/GRCh37
COPY GRCh38/results/ldscores/ /ldscores/GRCh38

COPY --from=astral/uv:latest /uv /uvx /usr/local/bin/

RUN git clone https://github.com/CBIIT/ldsc.git && \
    cd ldsc && \
    git checkout 0448dd3

RUN cd ldsc && \
    uv venv && \
    uv init --bare && \
    uv add -r requirements.txt && \
    sed -i 's|#!/usr/bin/env python|#!/ldsc/.venv/bin/python -W ignore|' *.py

ENV PATH="/ldsc:$PATH"

CMD ["ldsc.py", "-h"]
