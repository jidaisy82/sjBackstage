import { CheckResult } from '@backstage-community/plugin-tech-insights-common';

/**
 * DB 상태 체크 정의
 */
export const dbStatusChecks = [
  {
    id: 'db-connection-active',
    type: 'json-rules-engine',
    name: 'DB 연결 상태',
    description: '데이터베이스가 정상적으로 연결되어 있는지 확인',
    factIds: ['tech-blog-db-status-retriever'],
    rule: {
      conditions: {
        all: [
          {
            fact: 'dbConnectionStatus',
            operator: 'equal',
            value: true,
          },
        ],
      },
    },
  },
  {
    id: 'db-response-time-healthy',
    type: 'json-rules-engine',
    name: 'DB 응답 시간',
    description: '데이터베이스 응답 시간이 200ms 이하인지 확인',
    factIds: ['tech-blog-db-status-retriever'],
    rule: {
      conditions: {
        all: [
          {
            fact: 'dbResponseTime',
            operator: 'lessThanInclusive',
            value: 200,
          },
        ],
      },
    },
  },
  {
    id: 'db-disk-usage-normal',
    type: 'json-rules-engine',
    name: 'DB 디스크 사용률',
    description: '디스크 사용률이 80% 이하인지 확인',
    factIds: ['tech-blog-db-status-retriever'],
    rule: {
      conditions: {
        all: [
          {
            fact: 'dbDiskUsage',
            operator: 'lessThanInclusive',
            value: 80,
          },
        ],
      },
    },
  },
];

