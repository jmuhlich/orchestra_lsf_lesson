function dct_example_1

jm = findResource('scheduler','type','lsf');
set(jm, 'SubmitArguments', '-q sysbio_15m -R "rusage[matlab_dc_lic=1]"');

job = createJob(jm);

for i=1:5
  createTask(job, @max, 2, {rand(3)});
end

num_tasks = length(job.Tasks);
submit(job);
wait(job)
result = getAllOutputArguments(job);
destroy(job);

for i = 1:num_tasks
  disp(result{i});
end
