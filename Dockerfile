FROM ortussolutions/boxlang:miniserver
RUN rm /app/* -r 
ENV BOXLANG_PORT=10000
COPY ./ /app
EXPOSE 10000