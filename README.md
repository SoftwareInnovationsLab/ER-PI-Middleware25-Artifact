## ER-𝜋: Exhaustive Interleaving Replay for Testing Replicated Data Library Integration

This repository contains the artifact for the paper [ER-𝜋: Exhaustive Interleaving Replay for Testing Replicated Data Library Integration](https://people.cs.vt.edu/provakar/Middleware_25__ER_%f0%9d%9c%8b_.pdf), accepted at the [26th ACM/IFIP International Middleware Conference (Middleware 2025)](https://middleware-conf.github.io/2025/).

> <b>Abstract:</b> Modern replicated data systems often rely on libraries integrated with application code. These replicated data libraries exchange asynchronous messages, whose execution orderings are non-deterministic, allowing any message interleaving to occur during system execution. Testing the integration of application code with library code requires considering all possible interleavings, whose detection and simulation pose significant challenges for application developers. In this paper, we present ER-𝜋, a middleware system, designed to detect and replay possible interleavings in replicated data systems.ER-𝜋 identifies potential interleavings for a given code segment and applies four novel pruning techniques to reduce the complexity of the problem space. Subsequently, it replays the remaining interleavings to perform the specified integration testing tasks. To assess the applicability and efficacy of ER-𝜋, we integrated it with third-party replicated data libraries across various programming languages. Our experiments demonstrate ER-𝜋 ’s capability to replicate 12 known bugs and uncover 5 types of common misconceptions associated with replicated data libraries. Given that integration testing is essential for ensuring correctness and robustness, the design ofER-𝜋 holds promise in extending these testing benefits to the realm of replicated data systems.

This repository contains the source code of the ER-𝜋 framework and the replicated data libraries (RDLs) used for evalaution, along with all the required build and run scripts. The RDLs include Go_RDL, Java_RDL, OrbitDB_RDL, and Roshi. 

###  Prerequisite
 - [Docker](https://docs.docker.com/get-started/get-docker/)

### Clone the repository
```bash
git clone https://github.com/SoftwareInnovationsLab/ER-PI-Middleware25-Artifact.git
cd ER-PI-Middleware25-Artifact/
```

### Build the Docker Container
```bash
docker build -t erpi-artifact .
```
This will install all dependencies, including:
- Go, Node.js, Java, C++, and Python 3
- Redis server
- Gradle
- Soufflé Datalog

⚠️ <b>The first build may take several minutes</b> ⏳

### Run the Container
```bash
docker run -it --rm -v $(pwd)/artifact_logs:/artifact/artifact_logs erpi-artifact
```
This will:
- Start a shell inside the container.
- Map `/artifact/artifact_logs` to your host machine so you can view all the generated logs.

### Run ER-𝜋 for the Evaluated RDLs 

#### 1. Go_RDL
From inside the container:
```bash
cd RDL-Libraries/Go_RDL/
./goRDL_run.sh start
```

<b>Monitor progress:</b>
Check replica logs on your host machine:
`artifact_logs/Go_RDL/all_related_logs/r1.log`
`artifact_logs/Go_RDL/all_related_logs/r2.log`

<b>Stop and clean replicas:</b>
```
./goRDL_run.sh stop
./goRDL_run.sh clean
```

#### 2. Java_RDL
```
cd ../Java_RDL/
./crdts_run.sh start
```

<b>Monitor progress:</b>
Check test-result log on your host machine:
`artifact_logs/Java_RDL/all_related_logs/test_res.log`

<b>Stop and clean:</b>
```bash
./crdts_run.sh stop
./crdts_run.sh clean
```

#### 3. OrbitDB_RDL
```bash
cd ../OrbitDB_RDL/
./OrbitDB_run.sh start
```
<b>Monitor output at the console</b>

<b>Stop and clean:</b>
```
./OrbitDB_run.sh clean
```

#### 4. Roshi
```bash
cd ../roshi/
./roshi_run.sh start
```
<b>Monitor output at the console</b>

<b>Stop and clean:</b>
```
./roshi_run.sh clean
```

#### Viewing Logs

All logs are written to: `artifact_logs/` on your host machine. Each RDL module has its own `all_related_logs` directory.

### Citation
If you build upon this work, you can cite our paper:
```
@inproceedings{mondal2025er,
  title={ER-$\pi$: Exhaustive Interleaving Replay for Testing Replicated Data Library Integration},
  author={Mondal, Provakar and Tilevich, Eli},
  booktitle={Proceedings of the 26th International Middleware Conference},
  year={2025},
  doi = {10.1145/3721462.3730947}
}
```