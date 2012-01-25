function dct_example_2

jm = findResource('scheduler','type','lsf');
set(jm, 'SubmitArguments', '-q sysbio_15m -R "rusage[matlab_dc_lic=1]"');

job = createJob(jm);

for i=1:5
  createTask(job, @max, 2, {rand(3)});
end

num_tasks = length(job.Tasks);
submit(job);
while ~waitForState(job, 'finished', 1)
   disp(datestr(now, 31));
   for i=1:num_tasks
      fprintf(1, '%3d', i);
   end
   fprintf(1, '\n');
   for i=1:num_tasks
      fprintf(1, '%3s', upper(job.Tasks(i).State(1)));
   end
   fprintf(1, '\n\n');
end
result = getAllOutputArguments(job);
destroy(job);

for i = 1:num_tasks
  disp(result{i});
end
