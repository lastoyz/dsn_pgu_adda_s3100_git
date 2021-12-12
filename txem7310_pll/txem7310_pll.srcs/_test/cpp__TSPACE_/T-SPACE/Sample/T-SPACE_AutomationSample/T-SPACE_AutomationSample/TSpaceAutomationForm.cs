using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.IO;
using System.Threading;

// T-SPACE UI 제어 클래스를 사용하기위해 선언
// (Top.TSpace.Automation.dll 참조 추가 필요)
using Top.TSpace.Automation; 

namespace T_SPACE_AutomationSample
{
    public partial class TSpaceAutomationForm : Form
    {

        // T-SPACE UI 제어 자동화 클래스 객체 선언
        TSpaceAutomation TSpaceAuto = new TSpaceAutomation();

        public TSpaceAutomationForm()
        {
            InitializeComponent();
        }

        // ------------------------------------------------------------
        // 폼 로드시 T-SPACE Workspace 목록 업데이트
        // ------------------------------------------------------------
        private void TSpaceAutomationForm_Load(object sender, EventArgs e)
        {
            cmbRating.SelectedIndex = 0;
            UpdateWorkspaceNameList();            
        }
        

        // ------------------------------------------------------------
        // T-SPACE Workspace 목록 업데이트
        // ------------------------------------------------------------
        private void btnReload_Click(object sender, EventArgs e)
        {            
            UpdateWorkspaceNameList();
        }

        // ------------------------------------------------------------
        // Workspace 선택시 해당 Test Item 목록 업데이트
        // ------------------------------------------------------------
        private void cmbWorkspaceList_SelectedIndexChanged(object sender, EventArgs e)
        {
            string workspaceName;
            workspaceName = cmbWorkspaceList.Text;
            if (workspaceName.Trim() != "")
            {
                int i;
                string[] testItemNameList;

                // Workspace 선택 
                TSpaceAuto.SelectWorkspace(workspaceName); 

                // Workspace에 등록된 테스트 아이템 목록을 String 배열로 리턴
                testItemNameList = TSpaceAuto.GetTestItemNameList(); 

                lstTestItemList.Items.Clear();
                for (i = 0; i < testItemNameList.Length; i++)
                {
                    lstTestItemList.Items.Add(testItemNameList[i]);
                }                
            }
        }

        // ------------------------------------------------------------
        // Test Item List에서 선택한 측정 아이템 로드
        // ------------------------------------------------------------
        private void btnLoadTestItem_Click(object sender, EventArgs e)
        {
            try
            {
                int index = lstTestItemList.SelectedIndex;
                if (index < 0) return;
                string itemName = lstTestItemList.Items[index].ToString();                
                // 테스트 아이템 로드
                TSpaceAuto.LoadTestItem(itemName);
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message, "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }                
        }

        // ------------------------------------------------------------
        // 측정 아이템 실행
        // ------------------------------------------------------------
        private void btnRun_Click(object sender, EventArgs e)
        {
            try
            {
                // 테스트 아이템 실행
                TSpaceAuto.Run();
                btnStop.Focus();

                // 테스트 아이템 실행 완료까지 대기
                do
                {                
                    //Thread.Sleep(100);
                    Application.DoEvents();
                } while (TSpaceAuto.IsTesting);

                // 실행 완료후 자동 저장 데이터 파일명 리턴
                string fileName = TSpaceAuto.LastAutoSaveDataFileName;

                // 저장 데이터 파일을 읽어 측정 데이터 표시
                LoadAutoSaveTestDataFile(fileName);
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message, "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }

        // ------------------------------------------------------------
        // 측정 아이템 누적 실행
        // ------------------------------------------------------------
        private void btnAppend_Click(object sender, EventArgs e)
        {
            try
            {
                // 테스트 아이템 누적 실행
                TSpaceAuto.Append();
                btnStop.Focus();

                // 테스트 아이템 누적 실행 완료까지 대기
                do
                {
                    //Thread.Sleep(100);
                    Application.DoEvents();
                } while (TSpaceAuto.IsTesting);

                // 실행 완료후 자동 저장 데이터 파일명 리턴
                string fileName = TSpaceAuto.LastAutoSaveDataFileName;

                // 누적 저장 데이터 파일을 읽어 측정 데이터 표시
                LoadAutoSaveTestDataFile(fileName);
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message, "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }

        // ------------------------------------------------------------
        // 측정 아이템 반복 3회 실행 예제
        // ------------------------------------------------------------
        private void btnRepeat_Click(object sender, EventArgs e)
        {
            try
            {
                // 테스트 아이템 3회 반복 실행
                TSpaceAuto.Repeat(3);
                btnStop.Focus();

                // 테스트 아이템 3회 반복 실행 완료까지 대기
                do
                {
                    //Thread.Sleep(100);
                    Application.DoEvents();
                } while (TSpaceAuto.IsTesting);

                // 실행 완료후 자동 저장 데이터 파일명 리턴
                string fileName = TSpaceAuto.LastAutoSaveDataFileName;

                // 3회 반복 누적 저장 데이터 파일을 읽어 측정 데이터 표시
                LoadAutoSaveTestDataFile(fileName);
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message, "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }

        // ------------------------------------------------------------
        // 측정 아이템 실행 중지
        // ------------------------------------------------------------
        private void btnStop_Click(object sender, EventArgs e)
        {
            try
            {
                TSpaceAuto.TestStop();
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message, "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }

        // ------------------------------------------------------------
        // 데이터 리스트에서 측정후 자동 저장된 마지막 측정 데이터(파일) 삭제
        // ------------------------------------------------------------
        private void btnDeleteDataFile_Click(object sender, EventArgs e)
        {                   
            try
            {
                string fileName = TSpaceAuto.LastAutoSaveDataFileName;
                TSpaceAuto.DeleteAutoSaveDataFile(fileName, true);
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message, "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }           
        }

        // ------------------------------------------------------------
        // 측정 데이터 엑셀 파일으로 저장
        // ------------------------------------------------------------
        private void btnSaveExcelDataFile_Click(object sender, EventArgs e)
        {
            String filename;
            SaveFileDialog1.Filter = "Excel File(*.xlsx)|*.xlsx";
            if (SaveFileDialog1.ShowDialog(this) == DialogResult.OK)
            {
                filename = SaveFileDialog1.FileName;
                try
                {
                    TSpaceAuto.SaveExcelDataFile(filename);
                }
                catch (Exception ex)
                {
                    MessageBox.Show(ex.Message, "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                }
            }
        }

        // ------------------------------------------------------------
        // 데이터 리스트에서 측정후 자동 저장된 마지막 측정 데이터(파일) 평가 리뷰 설정
        // 활용예)  
        //         Star Rating 으로 측정 데이터 등급 평가 설정
        //         Device Name 또는 Comment에 판정 결과 텍스트로 설정
        // ------------------------------------------------------------
        private void btnApplyRating_Click(object sender, EventArgs e)
        {
            try
            {
                string fileName = TSpaceAuto.LastAutoSaveDataFileName;
                TSpaceAuto.SetRatingAutoSaveDataFile(fileName, cmbRating.SelectedIndex - 1, txtDeviceName.Text, txtComment.Text);
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message, "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }

        }

        // ------------------------------------------------------------
        // T-SPACE Workspace 목록 업데이트 함수
        // ------------------------------------------------------------
        public void UpdateWorkspaceNameList()
        {
            int i;
            string[] workspaceNameList;

            try
            {
                cmbWorkspaceList.Items.Clear();

                // 등록된 Workspace 목록을 String 배열로 리턴
                workspaceNameList = TSpaceAuto.GetWorkspaceNameList();

                for (i = 0; i < workspaceNameList.Length; i++)
                {
                    cmbWorkspaceList.Items.Add(workspaceNameList[i]);
                }

                if (cmbWorkspaceList.Items.Count > 0) cmbWorkspaceList.SelectedIndex = 0;

            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message, "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }

        // ------------------------------------------------------------
        // T-SPACE 측정시 자동 저장 데이터 파일 로드 예제 함수
        // : 저장된 [DATA] 영역에서 측정 데이터를 처리해서 표시
        // ------------------------------------------------------------
        public void LoadAutoSaveTestDataFile(string fileName)
        {
            txtTestResult.Clear();

            try
            {
                using (StreamReader sr = File.OpenText(fileName))
                {
                    string text = sr.ReadToEnd();
                    string[] lines = text.Split(new string[] { "\r\n" }, StringSplitOptions.None);
                    string[] splitData;
                    string lineText;
                    bool dataFlag = false;

                    foreach (string line in lines)
                    {
                        lineText = line.Trim();

                        // 측정 데이터 블럭 식별자 체크
                        if ((lineText != "") && (lineText[0] == '['))
                        {
                            if (lineText == "[TestData]")
                            {
                                dataFlag = true;
                                continue;
                            }
                            else
                            {
                                dataFlag = false;
                            }
                        }

                        // Data 처리
                        if (dataFlag)
                        {
                            splitData = lineText.Split(new string[] { "," }, StringSplitOptions.None);
                            lineText = "";
                            for (int n = 0; n < splitData.Length; n++)
                            {
                                if (splitData[0] == "No")
                                {
                                    // 측정 데이터 이름
                                    // 데이터 이름에 그래프축 정보 제거
                                    if (splitData[n].Contains("GraphX:")) splitData[n] = splitData[n].Remove(0, 7);
                                    if (splitData[n].Contains("GraphY:")) splitData[n] = splitData[n].Remove(0, 7);
                                    if (splitData[n].Contains("GraphY2:")) splitData[n] = splitData[n].Remove(0, 8);
                                    lineText = lineText + String.Format("{0,15}", splitData[n]);
                                }
                                else
                                {
                                    // 측정 데이터
                                    lineText = lineText + String.Format("{0,15}", splitData[n]);
                                }
                            }
                            txtTestResult.AppendText(lineText + "\r\n");
                        }
                    }
                    sr.Close();
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message, "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }

  
    }
}
