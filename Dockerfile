FROM tercen/flowsom:0.1.14

ENV RENV_VERSION 0.13.0
RUN R -e "install.packages('remotes', repos = c(CRAN = 'https://cran.r-project.org'))"
RUN R -e "remotes::install_github('rstudio/renv@${RENV_VERSION}')"


RUN R -e "install.packages('https://cran.r-project.org/src/contrib/Archive/locfit/locfit_1.5-9.4.tar.gz', repos=NULL, type='source')"
RUN R -e "remotes::install_github('ghar1821/TrackSOM')"

COPY . /operator
WORKDIR /operator

# RUN R -e "renv::consent(provided=TRUE);renv::restore(confirm=FALSE)"

ENV TERCEN_SERVICE_URI https://tercen.com

ENTRYPOINT [ "R","--no-save","--no-restore","--no-environ","--slave","-f","main.R", "--args"]
CMD [ "--taskId", "someid", "--serviceUri", "https://tercen.com", "--token", "sometoken"]