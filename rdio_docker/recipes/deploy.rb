include_recipe 'deploy'

node[:deploy].each do |application, deploy|

  if node[:opsworks][:instance][:layers].first != deploy[:environment_variables][:layer]
    Chef::Log.debug("Skipping deploy::docker application #{application} as it is not deployed to this layer")
    next
  end

  opsworks_deploy_dir do
    user deploy[:user]
    group deploy[:group]
    path deploy[:deploy_to]
  end

  opsworks_deploy do
    deploy_data deploy
    app application
  end

  bash "docker-cleanup" do
    user "root"
    code <<-EOH
      if docker ps -a | grep #{deploy[:application]}; 
      then
        docker stop #{deploy[:application]}
        sleep 3
        docker rm #{deploy[:application]}
        sleep 3
      fi
      if docker images | grep #{deploy[:application]}; 
      then
        docker rmi #{deploy[:application]}
	sleep 5
      fi
    EOH
  end

  bash "docker-build" do
    user "root"
    cwd "#{deploy[:deploy_to]}/current"
    code <<-EOH
      docker build -t=#{deploy[:application]} . > #{deploy[:application]}-docker.out
    EOH
  end

  dockerenvs = " "
  dockerports = " "
  deploy[:environment_variables].each do |key, value|
    dockerenvs=dockerenvs+" -e "+key+"="+value
    if key.end_with?('port')
      dockerports=dockerports+" -p " + node[:opsworks][:instance][:private_ip] + ":" + value
    end
  end

  bash "docker-run" do
    user "root"
    cwd "#{deploy[:deploy_to]}/current"
    code <<-EOH
      docker run #{dockerenvs} #{dockerports} -e ETCD_ADDR=#{node[:opsworks][:instance][:private_ip]}:4001 -e ETCD_PEER_ADDR=#{node[:opsworks][:instance][:private_ip]}:7001 --name #{deploy[:application]} -d #{deploy[:application]}
    EOH
  end

end

