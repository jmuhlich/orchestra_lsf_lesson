Matlab
======

.. highlight:: matlab

Example code
------------

Here is some MATLAB code for testing Sphinx::

    sched = findResource('scheduler','type','lsf');
    set(sched, 'SubmitArguments', '-q sysbio_15m -R "rusage[matlab_dc_lic=1]"');

    j = createJob(sched);

    for i=1:5
      createTask(j, @max, 2, {rand(3)});
    end

    num_tasks = length(j.Tasks);
    submit(j);
    while ~waitForState(j, 'finished', 1)
       disp(datestr(now, 31));
       for i=1:num_tasks
          fprintf(1, '%3d', i);
       end
       fprintf(1, '\n');
       for i=1:num_tasks
          fprintf(1, '%3s', upper(j.Tasks(i).State(1)));
       end
       fprintf(1, '\n\n');
    end
    result = getAllOutputArguments(j);
    destroy(j);

    for i = 1:num_tasks
      disp(result{i});
    end
