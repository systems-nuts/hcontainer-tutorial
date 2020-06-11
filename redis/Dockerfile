# Use an official Python runtime as a parent image
FROM ubuntu:18.04

# Set the working directory to /app
WORKDIR /app
# Copy the current directory contents into the container at /app
COPY . /app

CMD ["./redis-server","--protected-mode","no"]

