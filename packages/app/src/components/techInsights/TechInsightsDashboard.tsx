import { Grid } from '@material-ui/core';
import {
  Header,
  Page,
  Content,
  InfoCard,
} from '@backstage/core-components';

export const TechInsightsDashboard = () => {
  return (
    <Page themeId="tool">
      <Header
        title="Tech Insights"
        subtitle="시스템 전체의 기술 품질과 모범 사례 준수 현황"
      />
      <Content>
        <Grid container spacing={3}>
          <Grid item xs={12}>
            <InfoCard title="Tech Insights Overview">
              <p>
                Tech Insights는 시스템의 기술 품질과 모범 사례 준수 현황을 모니터링합니다.
                각 엔티티의 상세 정보는 Catalog에서 확인하실 수 있습니다.
              </p>
              <p>
                <strong>주요 기능:</strong>
              </p>
              <ul>
                <li>데이터베이스 연결 상태 모니터링</li>
                <li>응답 시간 측정 (목표: 200ms 이하)</li>
                <li>디스크 사용률 추적 (목표: 80% 이하)</li>
              </ul>
              <p>
                <strong>확인 방법:</strong><br />
                Catalog → Resources → tech-blog-database → Tech Insights 탭
              </p>
            </InfoCard>
          </Grid>
        </Grid>
      </Content>
    </Page>
  );
};

