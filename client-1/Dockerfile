FROM python:3.9-slim

ENV PYTHONPATH "${PYTHONPATH}:/app/"

WORKDIR /usr/app

RUN pip3 install requests scikit-learn tensorflow numpy
RUN pip3 install setuptools --upgrade

COPY trigger.py ./

EXPOSE 8000

CMD ["python", "./trigger.py"]
