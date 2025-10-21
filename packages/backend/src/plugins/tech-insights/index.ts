import { createBackendModule } from '@backstage/backend-plugin-api';
import { 
  techInsightsFactRetrieversExtensionPoint,
} from '@backstage-community/plugin-tech-insights-node';
import { coreServices } from '@backstage/backend-plugin-api';
import { DatabaseStatusFactRetriever } from './factRetrievers/dbStatusRetriever';

/**
 * Tech Insights 모듈 - DB 상태 모니터링 Fact Retriever 등록
 */
export default createBackendModule({
  pluginId: 'tech-insights',
  moduleId: 'db-status-retriever',
  register(env) {
    env.registerInit({
      deps: {
        factRetrievers: techInsightsFactRetrieversExtensionPoint,
        config: coreServices.rootConfig,
        logger: coreServices.logger,
      },
      async init({ factRetrievers, config, logger }) {
        logger.info('Initializing DB Status Fact Retriever...');
        
        // DB 상태 Fact Retriever 생성 (FactRetriever 객체)
        const dbStatusRetriever = new DatabaseStatusFactRetriever(config);
        
        // FactRetriever 객체를 직접 등록 (공식 문서 방식)
        // cadence는 app-config.yaml의 techInsights.factRetrievers.dbStatusFactRetriever.cadence에서 설정
        factRetrievers.addFactRetrievers({
          dbStatusFactRetriever: dbStatusRetriever,  // app-config.yaml의 key와 일치
        });
        
        logger.info(`DB Status Fact Retriever registered: ${dbStatusRetriever.id} v${dbStatusRetriever.version}`);
      },
    });
  },
});

