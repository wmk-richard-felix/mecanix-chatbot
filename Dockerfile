# Pull SDK image as base image
FROM rasa/rasa-sdk:2.3.1

# Use subdirectory as working directory
WORKDIR /app

# Copy actions requirements
COPY actions/requirements-actions.txt ./

# Change to root user to install dependencies
USER root

# Install extra requirements for actions code
RUN pip install -r requirements-actions.txt

# Copy actions code to working directory
COPY ./actions /app/actions

# Install modules from setup.py
COPY setup.py /app
RUN pip install . --no-cache-dir

# Download spacy language data
RUN python -m spacy download en_core_web_md
RUN python -m spacy link en_core_web_md en

# Don't use root user to run code
USER root
RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app
COPY . /usr/src/app
RUN rasa train --domain domain.yml --data data --out models

USER 1001
EXPOSE 5005

# Start the action server
# CMD ["start", "--actions", "actions.actions"]
ENTRYPOINT ["rasa"]
CMD ["run", "--enable-api" ]