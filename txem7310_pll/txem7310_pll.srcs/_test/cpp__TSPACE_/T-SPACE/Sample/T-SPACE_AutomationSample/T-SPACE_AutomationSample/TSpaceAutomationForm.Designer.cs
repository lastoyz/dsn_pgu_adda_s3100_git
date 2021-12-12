namespace T_SPACE_AutomationSample
{
    partial class TSpaceAutomationForm
    {
        /// <summary>
        /// 필수 디자이너 변수입니다.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// 사용 중인 모든 리소스를 정리합니다.
        /// </summary>
        /// <param name="disposing">관리되는 리소스를 삭제해야 하면 true이고, 그렇지 않으면 false입니다.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form 디자이너에서 생성한 코드

        /// <summary>
        /// 디자이너 지원에 필요한 메서드입니다.
        /// 이 메서드의 내용을 코드 편집기로 수정하지 마십시오.
        /// </summary>
        private void InitializeComponent()
        {
            this.btnRun = new System.Windows.Forms.Button();
            this.cmbWorkspaceList = new System.Windows.Forms.ComboBox();
            this.label1 = new System.Windows.Forms.Label();
            this.btnReload = new System.Windows.Forms.Button();
            this.label2 = new System.Windows.Forms.Label();
            this.lstTestItemList = new System.Windows.Forms.ListBox();
            this.btnLoadTestItem = new System.Windows.Forms.Button();
            this.label3 = new System.Windows.Forms.Label();
            this.txtTestResult = new System.Windows.Forms.TextBox();
            this.btnStop = new System.Windows.Forms.Button();
            this.btnAppend = new System.Windows.Forms.Button();
            this.btnRepeat = new System.Windows.Forms.Button();
            this.btnDeleteDataFile = new System.Windows.Forms.Button();
            this.btnApplyRating = new System.Windows.Forms.Button();
            this.btnSaveExcelDataFile = new System.Windows.Forms.Button();
            this.SaveFileDialog1 = new System.Windows.Forms.SaveFileDialog();
            this.groupBox1 = new System.Windows.Forms.GroupBox();
            this.txtComment = new System.Windows.Forms.TextBox();
            this.label6 = new System.Windows.Forms.Label();
            this.txtDeviceName = new System.Windows.Forms.TextBox();
            this.label5 = new System.Windows.Forms.Label();
            this.cmbRating = new System.Windows.Forms.ComboBox();
            this.label4 = new System.Windows.Forms.Label();
            this.groupBox1.SuspendLayout();
            this.SuspendLayout();
            // 
            // btnRun
            // 
            this.btnRun.Location = new System.Drawing.Point(261, 132);
            this.btnRun.Name = "btnRun";
            this.btnRun.Size = new System.Drawing.Size(150, 28);
            this.btnRun.TabIndex = 0;
            this.btnRun.Text = "RUN";
            this.btnRun.UseVisualStyleBackColor = true;
            this.btnRun.Click += new System.EventHandler(this.btnRun_Click);
            // 
            // cmbWorkspaceList
            // 
            this.cmbWorkspaceList.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.cmbWorkspaceList.Font = new System.Drawing.Font("굴림", 11.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.cmbWorkspaceList.FormattingEnabled = true;
            this.cmbWorkspaceList.Location = new System.Drawing.Point(22, 35);
            this.cmbWorkspaceList.Name = "cmbWorkspaceList";
            this.cmbWorkspaceList.Size = new System.Drawing.Size(227, 23);
            this.cmbWorkspaceList.TabIndex = 1;
            this.cmbWorkspaceList.SelectedIndexChanged += new System.EventHandler(this.cmbWorkspaceList_SelectedIndexChanged);
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(20, 20);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(79, 12);
            this.label1.TabIndex = 2;
            this.label1.Text = "Workspace : ";
            // 
            // btnReload
            // 
            this.btnReload.Location = new System.Drawing.Point(261, 33);
            this.btnReload.Name = "btnReload";
            this.btnReload.Size = new System.Drawing.Size(150, 28);
            this.btnReload.TabIndex = 3;
            this.btnReload.Text = "Update Workspace List";
            this.btnReload.UseVisualStyleBackColor = true;
            this.btnReload.Click += new System.EventHandler(this.btnReload_Click);
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Location = new System.Drawing.Point(20, 79);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(90, 12);
            this.label2.TabIndex = 4;
            this.label2.Text = "Test Item List :";
            // 
            // lstTestItemList
            // 
            this.lstTestItemList.Font = new System.Drawing.Font("굴림", 11.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lstTestItemList.FormattingEnabled = true;
            this.lstTestItemList.ItemHeight = 15;
            this.lstTestItemList.Location = new System.Drawing.Point(22, 97);
            this.lstTestItemList.Name = "lstTestItemList";
            this.lstTestItemList.Size = new System.Drawing.Size(227, 139);
            this.lstTestItemList.TabIndex = 5;
            // 
            // btnLoadTestItem
            // 
            this.btnLoadTestItem.Location = new System.Drawing.Point(261, 98);
            this.btnLoadTestItem.Name = "btnLoadTestItem";
            this.btnLoadTestItem.Size = new System.Drawing.Size(150, 28);
            this.btnLoadTestItem.TabIndex = 6;
            this.btnLoadTestItem.Text = "Load Test Item";
            this.btnLoadTestItem.UseVisualStyleBackColor = true;
            this.btnLoadTestItem.Click += new System.EventHandler(this.btnLoadTestItem_Click);
            // 
            // label3
            // 
            this.label3.AutoSize = true;
            this.label3.Location = new System.Drawing.Point(20, 259);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(106, 12);
            this.label3.TabIndex = 7;
            this.label3.Text = "Test Data Result :";
            // 
            // txtTestResult
            // 
            this.txtTestResult.Font = new System.Drawing.Font("굴림체", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.txtTestResult.Location = new System.Drawing.Point(22, 277);
            this.txtTestResult.Multiline = true;
            this.txtTestResult.Name = "txtTestResult";
            this.txtTestResult.ScrollBars = System.Windows.Forms.ScrollBars.Both;
            this.txtTestResult.Size = new System.Drawing.Size(545, 196);
            this.txtTestResult.TabIndex = 8;
            this.txtTestResult.WordWrap = false;
            // 
            // btnStop
            // 
            this.btnStop.Location = new System.Drawing.Point(417, 132);
            this.btnStop.Name = "btnStop";
            this.btnStop.Size = new System.Drawing.Size(150, 28);
            this.btnStop.TabIndex = 9;
            this.btnStop.Text = "STOP";
            this.btnStop.UseVisualStyleBackColor = true;
            this.btnStop.Click += new System.EventHandler(this.btnStop_Click);
            // 
            // btnAppend
            // 
            this.btnAppend.Location = new System.Drawing.Point(261, 166);
            this.btnAppend.Name = "btnAppend";
            this.btnAppend.Size = new System.Drawing.Size(150, 28);
            this.btnAppend.TabIndex = 10;
            this.btnAppend.Text = "Append";
            this.btnAppend.UseVisualStyleBackColor = true;
            this.btnAppend.Click += new System.EventHandler(this.btnAppend_Click);
            // 
            // btnRepeat
            // 
            this.btnRepeat.Location = new System.Drawing.Point(261, 201);
            this.btnRepeat.Name = "btnRepeat";
            this.btnRepeat.Size = new System.Drawing.Size(150, 28);
            this.btnRepeat.TabIndex = 11;
            this.btnRepeat.Text = "Repeat (3)";
            this.btnRepeat.UseVisualStyleBackColor = true;
            this.btnRepeat.Click += new System.EventHandler(this.btnRepeat_Click);
            // 
            // btnDeleteDataFile
            // 
            this.btnDeleteDataFile.Location = new System.Drawing.Point(417, 203);
            this.btnDeleteDataFile.Name = "btnDeleteDataFile";
            this.btnDeleteDataFile.Size = new System.Drawing.Size(150, 28);
            this.btnDeleteDataFile.TabIndex = 12;
            this.btnDeleteDataFile.Text = "Delete Data File";
            this.btnDeleteDataFile.UseVisualStyleBackColor = true;
            this.btnDeleteDataFile.Click += new System.EventHandler(this.btnDeleteDataFile_Click);
            // 
            // btnApplyRating
            // 
            this.btnApplyRating.Location = new System.Drawing.Point(456, 40);
            this.btnApplyRating.Name = "btnApplyRating";
            this.btnApplyRating.Size = new System.Drawing.Size(74, 28);
            this.btnApplyRating.TabIndex = 13;
            this.btnApplyRating.Text = "Apply";
            this.btnApplyRating.UseVisualStyleBackColor = true;
            this.btnApplyRating.Click += new System.EventHandler(this.btnApplyRating_Click);
            // 
            // btnSaveExcelDataFile
            // 
            this.btnSaveExcelDataFile.Location = new System.Drawing.Point(417, 166);
            this.btnSaveExcelDataFile.Name = "btnSaveExcelDataFile";
            this.btnSaveExcelDataFile.Size = new System.Drawing.Size(150, 28);
            this.btnSaveExcelDataFile.TabIndex = 14;
            this.btnSaveExcelDataFile.Text = "Save Excel Data File";
            this.btnSaveExcelDataFile.UseVisualStyleBackColor = true;
            this.btnSaveExcelDataFile.Click += new System.EventHandler(this.btnSaveExcelDataFile_Click);
            // 
            // groupBox1
            // 
            this.groupBox1.Controls.Add(this.txtComment);
            this.groupBox1.Controls.Add(this.label6);
            this.groupBox1.Controls.Add(this.txtDeviceName);
            this.groupBox1.Controls.Add(this.label5);
            this.groupBox1.Controls.Add(this.cmbRating);
            this.groupBox1.Controls.Add(this.label4);
            this.groupBox1.Controls.Add(this.btnApplyRating);
            this.groupBox1.Location = new System.Drawing.Point(22, 489);
            this.groupBox1.Name = "groupBox1";
            this.groupBox1.Size = new System.Drawing.Size(545, 81);
            this.groupBox1.TabIndex = 16;
            this.groupBox1.TabStop = false;
            this.groupBox1.Text = "Data File Review";
            // 
            // txtComment
            // 
            this.txtComment.Location = new System.Drawing.Point(245, 45);
            this.txtComment.Name = "txtComment";
            this.txtComment.Size = new System.Drawing.Size(198, 21);
            this.txtComment.TabIndex = 21;
            // 
            // label6
            // 
            this.label6.AutoSize = true;
            this.label6.Location = new System.Drawing.Point(243, 27);
            this.label6.Name = "label6";
            this.label6.Size = new System.Drawing.Size(68, 12);
            this.label6.TabIndex = 20;
            this.label6.Text = "Comment :";
            // 
            // txtDeviceName
            // 
            this.txtDeviceName.Location = new System.Drawing.Point(131, 45);
            this.txtDeviceName.Name = "txtDeviceName";
            this.txtDeviceName.Size = new System.Drawing.Size(100, 21);
            this.txtDeviceName.TabIndex = 19;
            // 
            // label5
            // 
            this.label5.AutoSize = true;
            this.label5.Location = new System.Drawing.Point(129, 27);
            this.label5.Name = "label5";
            this.label5.Size = new System.Drawing.Size(89, 12);
            this.label5.TabIndex = 18;
            this.label5.Text = "Device Name :";
            // 
            // cmbRating
            // 
            this.cmbRating.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.cmbRating.Font = new System.Drawing.Font("굴림", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.cmbRating.FormattingEnabled = true;
            this.cmbRating.Items.AddRange(new object[] {
            "Unknown",
            "0 Stars",
            "1 Star",
            "2 Stars",
            "3 Stars",
            "4 Stars",
            "5 Stars"});
            this.cmbRating.Location = new System.Drawing.Point(18, 42);
            this.cmbRating.Name = "cmbRating";
            this.cmbRating.Size = new System.Drawing.Size(99, 20);
            this.cmbRating.TabIndex = 17;
            // 
            // label4
            // 
            this.label4.AutoSize = true;
            this.label4.Location = new System.Drawing.Point(16, 27);
            this.label4.Name = "label4";
            this.label4.Size = new System.Drawing.Size(48, 12);
            this.label4.TabIndex = 14;
            this.label4.Text = "Rating :";
            // 
            // TSpaceAutomationForm
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(7F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(591, 586);
            this.Controls.Add(this.groupBox1);
            this.Controls.Add(this.btnSaveExcelDataFile);
            this.Controls.Add(this.btnDeleteDataFile);
            this.Controls.Add(this.btnRepeat);
            this.Controls.Add(this.btnAppend);
            this.Controls.Add(this.btnStop);
            this.Controls.Add(this.txtTestResult);
            this.Controls.Add(this.label3);
            this.Controls.Add(this.btnLoadTestItem);
            this.Controls.Add(this.lstTestItemList);
            this.Controls.Add(this.label2);
            this.Controls.Add(this.btnReload);
            this.Controls.Add(this.label1);
            this.Controls.Add(this.cmbWorkspaceList);
            this.Controls.Add(this.btnRun);
            this.Font = new System.Drawing.Font("굴림", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.Name = "TSpaceAutomationForm";
            this.Text = "T-SPACE Automation Sample";
            this.Load += new System.EventHandler(this.TSpaceAutomationForm_Load);
            this.groupBox1.ResumeLayout(false);
            this.groupBox1.PerformLayout();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Button btnRun;
        private System.Windows.Forms.ComboBox cmbWorkspaceList;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.Button btnReload;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.ListBox lstTestItemList;
        private System.Windows.Forms.Button btnLoadTestItem;
        private System.Windows.Forms.Label label3;
        private System.Windows.Forms.TextBox txtTestResult;
        private System.Windows.Forms.Button btnStop;
        private System.Windows.Forms.Button btnAppend;
        private System.Windows.Forms.Button btnRepeat;
        private System.Windows.Forms.Button btnDeleteDataFile;
        private System.Windows.Forms.Button btnApplyRating;
        private System.Windows.Forms.Button btnSaveExcelDataFile;
        internal System.Windows.Forms.SaveFileDialog SaveFileDialog1;
        private System.Windows.Forms.GroupBox groupBox1;
        private System.Windows.Forms.TextBox txtComment;
        private System.Windows.Forms.Label label6;
        private System.Windows.Forms.TextBox txtDeviceName;
        private System.Windows.Forms.Label label5;
        private System.Windows.Forms.ComboBox cmbRating;
        private System.Windows.Forms.Label label4;
    }
}

