MATLAB code
======

.. highlight:: matlab

Example 1
----

Here is some MATLAB code to launch a 5-task job, wait for it to
complete, and print the results::

    jm = findResource('scheduler','type','lsf');
    set(jm, 'SubmitArguments', '-q sysbio_15m -R "rusage[matlab_dc_lic=1]"');

    job = createJob(jm);

    for i=1:5
      createTask(job, @max, 2, {rand(3)});
    end

    submit(job);
    wait(job)
    result = getAllOutputArguments(job);
    destroy(job);

    for i = 1:num_tasks
      disp(result{i});
    end

Example 2
----

Here is code to do the same thing as above, but print the tasks'
status every second while they are running::

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
