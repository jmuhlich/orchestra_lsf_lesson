Introduction to LSF
====

.. highlight:: none

.. note:: For more complete LSF documentation, consult the full LSF
   documentation set at https://wiki.med.harvard.edu/doc/lsf/.  The
   *Running Jobs with Platform LSF* document
   (https://wiki.med.harvard.edu/doc/lsf/lsf_using/index.htm) is
   likely the most useful reference for end-users.

Introduction
----

Platform LSF is a system for managing resources among a group of computers.

Here's some of the terminology that you'll find used in relation to LSF in this and other documents:

Master host
   A system that performs overall coordination of the LSF cluster.  In
   our case, this is a set of several systems which are not
   user-accessible. You shouldn't have to deal with master hosts.

Submission host
   A system from which LSF jobs are submitted.  This is the shell
   sever you log into when you ssh to
   orchestra.med.harvard.edu. Physically there are three shell
   servers: ``balcony``, ``loge``, and ``mezzanine`` -- you will
   randomly be assigned to one of these hosts each time you ssh to
   orchestra.

Execution host
   A system where LSF jobs will actually run.  We also commonly call
   these "compute nodes".  In Orchestra, compute nodes are named after
   musical instruments with a three-digit number, a dash, and another
   three-digit number after the name.

Queue
   A container for LSF jobs. All jobs "live" in a queue.  Queues have
   various limits and attributes associated with them, which limit
   execution priority, the type of jobs that can run, what resources
   those jobs can access, who has access, and so forth.

Submitting Jobs
----

You will generally submit jobs to LSF using the ``bsub`` command.
``bsub`` takes a number of option arguments followed by a command line
to execute.  A trivial example would be to run the ``hostname`` command
via LSF::

    user@orchestra:~$ bsub hostname
    Job <1682> is submitted to default queue <normal>.
    user@orchestra:~$ 

You should be able to specify basically any valid command line to ``bsub``.

Monitoring Jobs and Hosts
----

There are several commands you may wish to use to see the status of
your jobs or the hosts they are running on.

bjobs
   lists information about LSF jobs.

bhosts
   lists information about LSF hosts.

The ``-w`` (wide) option to both of these commands is useful when some
of the columns in the output are truncated.

Terminating Jobs Before Completion
----

The ``bkill`` command can be used to kill LSF jobs before they
complete normally.  For example, if you have a long-running job whose
output you are monitoring, and decide partway through the run that
it's not worth completing, you can kill it early.  Run ``bkill 1234``,
substituting your job's ID for ``1234``.  The job ID is the number in
the first column of ``bjobs`` output.

In rare cases, for example if a compute node crashes while running
your job, a job may be listed in the ``ZOMBIE`` state.  If this happens,
you can force that job's removal from the queue by using ``bkill -r``.

Job Completion
----

By default, you will receive an execution report by e-mail when a job
you have submitted to LSF completes.  If you expect your job to have
large amount of output on standard output or standard error, you
should probably use the ``-e`` or ``-o`` flags to ``bsub`` to direct
those streams to files.

Here's an example of a typical job report::

    Subject: Job 1682: <hostname> Done
    From: LSF <lsfadmin@orchestra.med.harvard.edu>
    Date: 25 Oct 2004 14:22:05 -0000 (Mon 10:22 EDT)
    To: user@orchestra.med.harvard.edu

    Job <hostname> was submitted from host <loge.med.harvard.edu> by user <user>.
    Job was executed on host(s) <clarinet002-070.orchestra>, in queue <normal>, as user <user>.
    </home/user> was used as the home directory.
    </home/user> was used as the working directory.
    Started at Mon Oct 25 10:22:04 2004
    Results reported at Mon Oct 25 10:22:05 2004

    Your job looked like:

    ------------------------------------------------------------
    # LSBATCH: User input
    hostname
    ------------------------------------------------------------

    Successfully completed.

    Resource usage summary:

        CPU time   :      0.01 sec.
        Max Memory :         2 MB
        Max Swap   :         4 MB

        Max Processes  :         1
        Max Threads    :         1

    The output (if any) follows:

    clarinet002-070

Job output handling and email size limits
----

Email sent from Orchestra systems has a maximum size limit of
**20MB**, equivalent to the limit imposed by the HMS e-mail servers
and most HMS-affiliated institutions.

If the size of your job output exceeds 20MB, the output will be placed
in a file in your home directory beneath the directory ``~/.lsbatch/``
and you will receive email with the exact location of the job output
file.  Note that this output directory is located underneath your home
directory, and is subject to the file system quota imposed on this
directory (usually 50GB).

If you are expecting very large output from your job, please remember
to direct the output to files using one of the following methods:

The -o/-e options to bsub
^^^^

The ``-o`` and ``-e`` options to ``bsub`` redirect
job output to a file::

   $ bsub -o myjob.out -e myjob.err myjob

The job report will be located at the beginning of the file myjob.out.
If you'd still like to receive an e-mail with just the job report, you
may also specify the ``-N`` option::

   $ bsub -N -o myjob.out -e myjob.err myjob

If you omit the ``-e`` option, both the standard output and standard error
will be located in the file specified after the ``-o`` option.

If you use the code ``%I`` in the output filename for either option,
it will automatically be replaced with the job ID. This is convenient
in scripts which will generate many jobs at once, so that each job
outputs to a different file.

Command line redirection
^^^^

Use the standard shell output redirection syntax::

   bsub 'myjob > myjob.out 2> myjob.err'

Note the command and the redirection must be quoted so that the output
of the job is redirected rather than the output of ``bsub`` itself.

Interactive Jobs
----

You can submit "interactive" jobs under LSF, which allows you to take
advantage of the execution hosts in the cluster, but while still
monitoring your job interactively, instead of having to submit your
job and wait for completion to view its complete output.  This can be
useful for testing jobs before you fully automate them, or simply for
running jobs where you'd like to interact with them while they're
running.

For example, say you have a large set of C source code that you're
developing and want to compile, but you'd like to see the compilation
as it occurs so you can quickly deal with any errors.  You can request
a shell on one of the execution hosts::

    user@orchestra ~ % bsub -Is -q shared_int_2h bash
    Job <1672> is submitted to default queue <normal>.
    <<Waiting for dispatch ...>>
    <<Starting on violin056.cl.med.harvard.edu>>
    user@violin056:~$

You can then run your commands, and exit the shell when you're done.

Note that only some LSF queues accept interactive jobs.  Our local
convention is to include ``int`` in those queues' names.

X11 Jobs
----

If you have SSH X11 forwarding enabled in your SSH client and are
running an X11 server on your local system, you can run X11 jobs on
the Orchestra compute nodes.  You can either ``bsub`` an X11 job, or
run an X11 command from within an interactive shell (one submitted
with ``bsub -I`` as described above).

If you just want to test this, a very simple X11 program is ``xlogo``,
which displays the X Window System logo.

Requesting resources
----

You may want to request a node with specific resources for your job.
For example, your job may require 4GB of free memory in order to run.
You can add resource requirements to ``bsub`` or ``bhosts`` using the
``-R`` option.  By using ``bhosts`` first, you can determine if there
are any hosts that match your requirements before submitting the job.
Note this reports only the amount of free memory as opposed to
installed memory, so a node with 32GB installed will have the
operating system and other system programs running that will use up
some of that space, so we recommend you look up to about 30GB.

*Jobs that use excessive memory without requesting resources may be
terminated by RITG to allow other jobs to run.* Please contact RITG at
http://ritg.med.harvard.edu/support/ if you have questions about your
job.

List the hosts with more than 30,000MB (about 30GB) of free memory::

    mfk8@orchestra:~$ bhosts -R "mem > 30000"

List the hosts with more than 10,000MB (about 10GB) of free space in ``/tmp`` for shared nodes::

    mfk8@orchestra:~$ bhosts -R "tmp > 10000" shared

Submit a job to the shared_15m queue to run on a node that has at least 100MB free memory and at least 1000MB (about 1GB) available in ``/tmp``::

    mfk8@orchestra:~$ bsub -q shared_15m -R "tmp > 1000 && mem > 100" hostname

Submit a job to the shared_15m queue to run on a node and reserve 8GB of memory for the duration of the job::

    mfk8@orchestra:~$ bsub -q shared_15m -R "rusage[mem=8000]" your_job

The two most common resources requested are available free memory
(``mem``) and available space in ``/scratch`` (``scratch``), with a full
list available using ``lsinfo -r``.  More information on using resource
requirements can be found in the man page for ``bsub``.

Default memory requirements
----

To ensure that LSF jobs are submitted to compute nodes with sufficient
available memory, and to protect against memory exhaustion on compute
nodes, LSF will impose a default memory reservation of 2GB and a
default memory limit of 8GB.  Memory exhaustion can adversely impact
other running jobs, prevent the dispatch of new jobs, can eventually
cause nodes to crash, and unfairly benefits a few intensive users at
the expense of all other users of that node.  With these defaults in
place, LSF will ensure that a job is dispatched to a node which has at
least 2GB of memory free and will reserve this 2GB of memory for the
duration of the job.  If the job consumes more than 8GB of memory, LSF
will automatically terminate the job.  *These defaults are not a
substitute for explicit specification of the memory requirements of
your job*.  You should always explicitly specify resource requirements
at job submission time.  If your job requires greater than 2GB of
memory, you should override the defaults by explicitly specifying a
memory reservation.  For example, if your job requires 16GB of memory,
you can specify this reservation via the ``-R`` option to bsub::

    mfk8@orchestra:~$ bsub -R "rusage[mem=16384]" your_job

Note that the units for memory reservation values are specified in MB.
Memory limits can be specified with the ``-M`` option and values are
specified in KB.  If an explicit memory reservation has been
specified, it is unnecessary to also specify an explicit memory limit
because the limit will be automatically determined based on the
explicit reservation.  If no explicit reservation has been specified,
you can specify a limit between the default reservation (2GB) and the
default limit (8GB) and this limit will be applied.

Memory reservations are per slot whereas memory limits are per job.
For parallel jobs or jobs requiring multiple slots to run, the
automatic limit will be the product of the explicit reservation
multiplied by the number of processors requested via the ``-n`` option.
For example, for the following ``bsub`` invocation that specifies 4
processors and a reservation of 4GB per processor::

    mfk8@orchestra:~$ bsub -n 4 -R "rusage[mem=4096]" your_job

The automatic limit will be 16GB (or 16384MB or 16777216KB).
