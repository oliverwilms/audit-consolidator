ARG IMAGE=intersystemsdc/iris-community
FROM $IMAGE

COPY --chown=irisowner:irisowner files /usr/irissys/mgr/

WORKDIR /home/irisowner/irisdev

ARG TESTS=0
ARG MODULE="audit-consolidator"
ARG NAMESPACE="%SYS"

ENV PIP_TARGET=${ISC_PACKAGE_INSTALLDIR}/mgr/python
ENV PYTHONPATH=${ISC_PACKAGE_INSTALLDIR}/mgr/python

RUN --mount=type=bind,src=.,dst=. \
#    pip3 install -r requirements.txt && \
    iris start IRIS && \
    iris session IRIS < iris.script && \
    ([ $TESTS -eq 0 ] || iris session iris -U $NAMESPACE "##class(%ZPM.PackageManager).Shell(\"test $MODULE -v -only\",1)") && \
    iris stop IRIS quietly
