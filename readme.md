Teamcity docker agent
=====================

This is the teamcity docker agents we run on our teamcity server
comes with builtin support for node, php and golang as well as ansible and docker in docker for CI testing.


# Complications

### Docker in docker
Running docker_in_docker is a real pain the ass, this is the best way we have managed to do it.

Mount the `/var/run/docker.sock` inside the container so use the host docker instance. 
But we also need to mount a workdir per agent else having multiple builds on the same project with the same hash will collide, so we need each agent to have a distinct workdir that is mounted under the same path on the host machine.


# How to run

This is our startup script for running 5 docker agents

```
docker run -d \
	--restart=always \
	--dns=8.8.8.8 --dns=8.8.4.4 \
	--name=agent-1 \
	-v /opt/agent-1:/data/teamcity_agent/conf \
	-v /opt/agent-1-composer:/root/.composer \
	-v /opt/agent-1-workdir:/opt/agent-1-workdir \
	-v /var/run/docker.sock:/var/run/docker.sock \
	-e AGENT_NAME=agent-1 -e SERVER_URL=https://teamcity.interactivesolutions.se interactivesolutions/teamcity-agent

docker exec -ti agent-1 bash -c "sed -i '18s/.*/workDir=\/opt\/agent-1-workdir/' /data/teamcity_agent/conf/buildAgent.properties"

docker run -d \
	--restart=always \
	--dns=8.8.8.8 --dns=8.8.4.4 \
	--name=agent-2 \
	-v /opt/agent-2:/data/teamcity_agent/conf \
	-v /opt/agent-2-composer:/root/.composer \
	-v /opt/agent-2-workdir:/opt/agent-2-workdir \
	-v /var/run/docker.sock:/var/run/docker.sock \
	-e AGENT_NAME=agent-2 -e SERVER_URL=https://teamcity.interactivesolutions.se interactivesolutions/teamcity-agent

docker exec -ti agent-2 bash -c "sed -i '18s/.*/workDir=\/opt\/agent-2-workdir/' /data/teamcity_agent/conf/buildAgent.properties"

docker run -d \
	--restart=always \
	--dns=8.8.8.8 --dns=8.8.4.4 \
	--name=agent-3 \
	-v /opt/agent-3:/data/teamcity_agent/conf \
	-v /opt/agent-3-composer:/root/.composer \
	-v /opt/agent-3-workdir:/opt/agent-3-workdir \
	-v /var/run/docker.sock:/var/run/docker.sock \
	-e AGENT_NAME=agent-3 -e SERVER_URL=https://teamcity.interactivesolutions.se interactivesolutions/teamcity-agent

docker exec -ti agent-3 bash -c "sed -i '18s/.*/workDir=\/opt\/agent-3-workdir/' /data/teamcity_agent/conf/buildAgent.properties"

docker run -d \
	--restart=always \
	--dns=8.8.8.8 --dns=8.8.4.4 \
	--name=agent-4 \
	-v /opt/agent-4:/data/teamcity_agent/conf \
	-v /opt/agent-4-composer:/root/.composer \
	-v /opt/agent-4-workdir:/opt/agent-4-workdir \
	-v /var/run/docker.sock:/var/run/docker.sock \
	-e AGENT_NAME=agent-4 -e SERVER_URL=https://teamcity.interactivesolutions.se interactivesolutions/teamcity-agent

docker exec -ti agent-4 bash -c "sed -i '18s/.*/workDir=\/opt\/agent-4-workdir/' /data/teamcity_agent/conf/buildAgent.properties"

docker run -d \
	--restart=always \
	--dns=8.8.8.8 --dns=8.8.4.4 \
	--name=agent-5 \
	-v /opt/agent-5:/data/teamcity_agent/conf \
	-v /opt/agent-5-composer:/root/.composer \
	-v /opt/agent-5-workdir:/opt/agent-5-workdir \
	-v /var/run/docker.sock:/var/run/docker.sock \
	-e AGENT_WORKDIR=/opt/work5 -e AGENT_NAME=agent-5 -e SERVER_URL=https://teamcity.interactivesolutions.se interactivesolutions/teamcity-agent

docker exec -ti agent-5 bash -c "sed -i '18s/.*/workDir=\/opt\/agent-5-workdir/' /data/teamcity_agent/conf/buildAgent.properties"
```
