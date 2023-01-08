FROM python:3.9-slim

ENV PYTHONPATH "${PYTHONPATH}:/app/"

WORKDIR /usr/app

RUN pip3 install requests

COPY trigger.py ./

EXPOSE 8000

CMD ["python", "./trigger.py"]
