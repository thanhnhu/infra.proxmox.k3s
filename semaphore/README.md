version: '3'
services:
  semaphore:
    image: semaphoreui/semaphore
    ports:
      - "3000:3000"
    environment:
      SEMAPHORE_DB_DIALECT: bolt

# docker-compose up -d