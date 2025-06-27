# DID Besu Contract

**did-besu-contract** 는 OpenDID EVM Contract를 구현한 프로젝트로, 블록체인 상에서 DID Document(DID 문서)와 Verifiable Credential Metadata(VC 메타데이터)를 저장하고 관리하는 기능을 제공합니다.
이 프로젝트는 분산 신원(DID) 및 **검증 가능한 자격 증명(VC)** 을 지원하기 위해 설계되었습니다.

<br>

## S/W 사양

- **스마트 컨트랙트**: solidity 0.8.27 <=
- **개발 환경**: Hardhat 2.22.19 <=, NodeJs 22.12.0 <=
- **블록체인 네트워크**: Ethereum 기반 네트워크

---

## Contract 주요 기능

- **DID Document 관리**: DID 문서를 블록체인에 저장, 조회, 업데이트, 상태 변경 등의 기능을 제공합니다.
- **VC Metadata 관리**: Verifiable Credential의 메타데이터를 저장하고 관리할 수 있습니다.
- **ZKP Data 관리**: ZKP 관련 데이터를 블록체인에 저장, 조회 기능을 제공합니다.
- **확장성**: OpenZeppelin 라이브러리를 활용하여 업그레이드 가능한 스마트 컨트랙트를 지원합니다.
- **권한확인**: OpenZeppelin 라이브러리를 활용하여 권한 확인 기능을 지원합니다.

---

## 설치 및 배포

> Besu에서 제공하는 test network를 사용하여 손쉽게 EVM 환경의 네트워크를 구축할 수 있습니다.
> 아래 단계에서 안내하고 있는 네트워크 실행 및 Contract의 배포 과정은 [Hyperledger Besu - start node](https://besu.hyperledger.org/private-networks/get-started/start-node) 및 [Hardhat - deploying to a live network](https://hardhat.org/tutorial/deploying-to-a-live-network) 를 참고하시기 바랍니다.

### 1. 의존성 설치

```bash
npm install
```

### 2. 컴파일

스마트 컨트랙트를 컴파일하려면 다음 명령어를 실행하세요:

```bash
npx hardhat compile
```

### 3. 배포

스마트 컨트랙트를 배포하려면 다음 명령어를 실행하세요:

```bash
npx hardhat run scripts/deploy.js --network <network-name>
```

<br>

---

#### 배포 스크립트 예시

```javascript
  const DocumentStorage = await ethers.getContractFactory(
      "DocumentStorage",
  );
  const documentStorage = await DocumentStorage.deploy();
  const documentStorageAddress = await documentStorage.getAddress();

  const VcMetaStorage = await ethers.getContractFactory(
      "VcMetaStorage",
  );
  const vcMetaStorage = await VcMetaStorage.deploy();
  const vcMetaStorageAddress = await vcMetaStorage.getAddress();

  const OpenDID = await ethers.getContractFactory(
      "OpenDID",
  );

  const openDIDProxy = await upgrades.deployProxy(OpenDID, [
      documentStorageAddress,
      vcMetaStorageAddress,
  ], {
      kind: "uups",
  });

  await openDIDProxy.waitForDeployment();
```

---

### 4.테스트

테스트를 실행하려면 다음 명령어를 사용하세요:

```bash
npx hardhat test
```

실행을 했을 때의 결과는 아래와 같습니다.

```bash
  VcMetaStorage
    Deployment
      ✔ Should emit DocumentStorageSetup event on initialization
    VcMetaStorage
      ✔ Should store a vcmeta
      ✔ should update a vcmeta status
    VcSchemaMetaStorage
      ✔ Should register a vc schema meta

  ZKPStorage
    Deployment
      ✔ Should emit DocumentStorageSetup event on initialization
    ZKPStorage
      ✔ Should store a schemas
Stored schema value:  Result(5) [ '', '', '', Result(0) [], '' ]
      ✔ Should remove a schema
      ✔ Should store a credential deifinition
      ✔ Should remove a credential definition
```
---

### 참고 링크
자세한 정보는 아래의 링크를 통해서 참고하시기 바랍니다.

- [hardhat](https://hardhat.org)
- [solidity 0.8.27](https://docs.soliditylang.org/en/v0.8.27/)
- [Besu](https://besu.hyperledger.org)

---

## 실행 예시

OpenDID Solidity Contract는 `Hardhat` 프레임워크를 활용하여 작성하였습니다.
`OpenDID.sol` 파일의 내용을 확인하여 호출 가능한 매서드 정보를 확인할 수 있습니다.

아래는 `curl`을 활용하여 contract를 호출하는 예시 입니다.

### contract 호출

```bash
curl -X POST \
--data '{"jsonrpc":"2.0","method":"eth_call","params":[{"to":"0x69498dd54bd25aa0c886cf1f8b8ae0856d55ff13","value":"0x1"}, "latest"],"id":53}' \ 
http://127.0.0.1:8545/ \
-H "Content-Type: application/json"
```

### 실행 결과

```json
{
  "jsonrpc": "2.0",
  "id": 1337,
  "result": "0x"
}
```

---

## 디렉토리 구조

<br>

```plaintext
did-besu-contract
├── contracts/          # 스마트 컨트랙트 코드
    ├── data/           # 데이터용 컨트랙트 라이브러리
    ├── storage/        # 저장용 컨트랙트 코드
    └── utils/          # 유틸성 컨트랙트 라이브러리
├── test/               # 테스트 코드
├── scripts/            # 배포 스크립트
├── artifacts/          # 컴파일된 아티팩트
├── cache/              # Hardhat 캐시
├── data/               # 샘플 데이터 및 스키마
└── doc/                # 문서화 자료
```

각 폴더와 파일에 대한 설명은 다음과 같습니다:

---

### Contract 관련 구조 설명

<br>

| 이름              | 설명                        |
| ----------------- | --------------------------- |
| docs              | 문서화                      |
| contracts         | 스마트 컨트랙트 폴더        |
| data              | 데이터 라이브러리 저장 경로 |
| storage           | 저장 컨트랙트 저장 경로     |
| utils             | 유틸 라이브러리 저장 경로   |
| hardhat.config.js | hardhat 프로젝트 설정       |
| scripts           | 프로젝트 연관 스크립트 목록 |

---

### 기타 디렉토리 구조 설명

<br>

| 이름                    | 설명                                     |
| ----------------------- | ---------------------------------------- |
| CHANGELOG.md            | 프로젝트의 버전별 변경 사항              |
| CODE_OF_CONDUCT.md      | 기여자 행동 강령                         |
| CONTRIBUTING.md         | 기여 지침과 절차                         |
| LICENSE                 | 라이선스                                 |
| dependencies-license.md | 프로젝트 의존 라이브러리의 라이선스 정보 |
| MAINTAINERS.md          | 프로젝트 유지 관리자 지침                |
| RELEASE-PROCESS.md      | 새 버전 릴리스 절차                      |
| SECURITY.md             | 보안 정책 및 취약성 보고 방법            |
