import os, subprocess, pandas as pd

path = "/farmacologia/home/farmauser/PRS/weights"
os.chdir(path) #os.getcwd() to know the current directory

#run
def run(cmd, pipefail=True, **kwargs):
    # Often advisable to manually run the command with stdbuf -i0 -o0 -e0
    return subprocess.run(f'set -eu{"o pipefail" if pipefail else ""}; {cmd}',
                          check=True, shell=True, executable='/bin/bash',
                          **kwargs)


#run_slurm
def run_slurm(cmd, job_name, time, log_file='/dev/null', num_threads=1,
              mem_per_cpu='16000M'):
    # 16000 MiB = 15.625 GiB, the memory per CPU on the 12-CPU SCC nodes:
    # $ scontrol show node node03 | grep CfgTRES
    # CfgTRES=cpu=12,mem=187.50G,billing=58
    assert ' ' not in job_name
    from tempfile import NamedTemporaryFile
    try:
        with NamedTemporaryFile('w', dir='.', suffix='.sh',
                                delete=False) as temp_file:
            print(f'#!/bin/bash\n'
                  f'#SBATCH --job-name={job_name}\n'
                  f'#SBATCH --time={time}\n'
                  f'#SBATCH --cpus-per-task={num_threads}\n'
                  f'#SBATCH --mem-per-cpu={mem_per_cpu}\n'
                  f'#SBATCH --output={log_file}\n'
                  f'export MKL_NUM_THREADS={num_threads}\n'
                  f'set -euo pipefail; {cmd}\n',
                  file=temp_file)
        sbatch_message = run(f'sbatch {temp_file.name}',
                             capture_output=True).stdout.decode().rstrip('\n')
        print(f'{sbatch_message} ("{job_name}")')
    finally:
        try:
            os.unlink(temp_file.name)
        except NameError:
            pass  #define run_slurm module


#sumstats
sumstats = {
  'SZexample': '/sumstats_QCed/SZexample.sumstats',
  'BDexample': '/sumstats_QCed/BDexample.sumstats',
  'IQexample': '/sumstats_QCed/IQexample.sumstats',
}

# Get N for each GWAS
N = {
  'SZexample': 108604.5,
  'BDexample': 14536.05,
  'IQexample': 269867,
}

num_threads = 12
for phenotype in sumstats:
      os.makedirs(f'weights/{phenotype}/logs', exist_ok=True)
      for chrom in range(1, 23):
        chrom_PRS_weight_file = f'{phenotype}/chr{chrom}.weights'
        if not os.path.exists(chrom_PRS_weight_file):
          run_slurm(
                f'MKL_NUM_THREADS={num_threads} '
                f'NUMEXPR_NUM_THREADS={num_threads} '
                f'OMP_NUM_THREADS={num_threads} '
                f'time '
                f'stdbuf -o0 -e0 '
                f'python /farmacologia/home/farmauser/PRS/PRScs/PRScs.py '
                f'--ref_dir=/farmacologia/home/farmauser/PRS/ldblk_ukbb '
                f'--bim_prefix=/farmacologia/home/farmauser/PRS/ukbb_bim/'
                    f'ukb_impeur_chr{chrom} '
                f'--sst_file=/farmacologia/home/farmauser/PRS/sumstats_QCed/{phenotype}.sumstats '
                f'--n_gwas={round(N[phenotype])} '
                f'--out_dir={phenotype}/ '
                f'--n_iter 10000 '
                f'--n_burnin 5000 '
                f'--chrom={chrom} '
                f'--seed=0 && '
                f'mv {phenotype}/_pst_eff_a1_b0.5_phiauto_'
                f'chr{chrom}.txt {chrom_PRS_weight_file}',
                job_name=f'weights_{phenotype}_chr{chrom}',
                time='1-00:00:00',
                log_file=f'weights/{phenotype}/logs/chr{chrom}.log',
                num_threads=num_threads)
                
