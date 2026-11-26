FROM python:3.13.18-trixie

COPY GRCh37/results/ldscores/ /ldscores/GRCh37
COPY GRCh38/results/ldscores/ /ldscores/GRCh38

COPY --from=astral/uv:0.13.10 /uv /uvx /usr/local/bin/

RUN git clone https://github.com/CBIIT/ldsc.git && \
    cd ldsc && \
    git checkout 0448dd3 && \
    uv venv && \
    uv init --bare && \
    uv add --exclude-newer 2026-11-26T00:00:00Z -r requirements.txt && \
    sed -i 's|#!/usr/bin/env python|#!/ldsc/.venv/bin/python -W ignore|' *.py

ENV PATH="/ldsc:$PATH"

CMD ["ldsc.py", "-h"]
