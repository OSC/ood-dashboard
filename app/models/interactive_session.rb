class InteractiveSession
  include ActiveModel::Model
  include ActiveModel::Serializers::JSON

  attr_accessor :id, :host, :job_id

  class << self
    def database_path
      OodAppkit.dataroot.join('db').tap { |p| p.mkpath unless p.exist? }
    end

    def all
      database_path.children.select(&:file?).map do |f|
        new.from_json(f.read)
      end.map do |s|
        s.completed? && s.destroy ? nil : s
      end.compact
    end

    def find(id)
      new.from_json(database_path.join(id).read)
    end
  end

  def database_file
    self.class.database_path.join(id) if id
  end

  def persisted?
    database_file && database_file.file?
  end

  def save
    if valid?
      stage && submit
    else
      false
    end
  end

  def destroy
    adapter.delete(id: job_id) unless completed?
    database_file.delete
    true
  rescue OodJob::Adapter::Error => e
    false
  end

  def stage
    `rsync -av --delete ./template/ #{staged_path}`
    $?.success?
  end

  def submit
    self.id = SecureRandom.uuid
    self.job_id = adapter.submit(script: script)
    database_file.write(to_json)
    true
  rescue OodJob::Adapter::Error => e
    false
  end

  def status
    @status || update_status
  end

  def update_status
    @status = adapter.status(id: job_id) if persisted?
  end

  def queued?
    status.queued?
  end

  def held?
    status.queued_held?
  end

  def suspended?
    status.suspended?
  end

  def starting?
    status.running? && !conn_file.file?
  end

  def running?
    status.running? && !starting?
  end

  def completed?
    status.undetermined?
  end

  def script
    OodJob::Script.new(
      content: script_content,
      job_name: "vnc_job",
      workdir: staged_path,
      output_path: out_file,
      wall_time: 3600,
      join_files: true,
      nodes: { procs: 1, properties: "oakley" }
    )
  end

  def adapter
    OodJob::Adapters::Torque.new(cluster: OodAppkit.clusters[host])
  end

  def script_content
    BatchConnect::Scripts::VNC.new(
      yml: conn_file,
      vnc_passwd: passwd_file,
      vnc_log: log_file
    ).render
  end

  def connect
    Dir.open(conn_file.dirname.to_s).close # force nfs cache refresh
    BatchConnect::Connections::VNC.new(yml: conn_file)
  end

  def staged_path
    OodAppkit.dataroot.join("staged").tap { |p| p.mkpath unless p.exist? }
  end

  def output_path
    OodAppkit.dataroot.join("output").tap { |p| p.mkpath unless p.exist? }
  end

  def conn_file
    persisted? ? output_path.join("#{job_id}.yml") : output_path.join("${PBS_JOBID}.yml")
  end

  def log_file
    persisted? ? output_path.join("#{job_id}.log") : output_path.join("${PBS_JOBID}.log")
  end

  def out_file
    persisted? ? output_path.join("#{job_id}.out") : output_path.join("${PBS_JOBID}.out")
  end

  def passwd_file
    persisted? ? output_path.join("#{job_id}.pass") : output_path.join("${PBS_JOBID}.pass")
  end

  def attributes=(hash)
    hash.each do |key, value|
      send("#{key}=", value)
    end
  end

  def attributes
    { "id" => nil, "host" => nil, "job_id" => nil }
  end
end
