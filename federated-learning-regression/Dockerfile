FROM python:3.9-slim
COPY ./app /app
COPY ./requirements.txt /app

ENV PYTHONPATH "${PYTHONPATH}:/app/"

WORKDIR /app

RUN pip3 install -r requirements.txt

EXPOSE 8000

CMD ["uvicorn", "main:app", "--host=0.0.0.0", "--reload"]
