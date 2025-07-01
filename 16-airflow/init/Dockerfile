FROM apache/airflow:3.0.2

COPY custom-requirements.txt .

RUN pip install -r custom-requirements.txt

# # make settings under root
# USER root

# # add a possible docker socket GID of host, 984
# RUN groupadd -g 984 docker || true 
# RUN usermod -aG docker airflow
# RUN newgrp docker

# USER airflow
