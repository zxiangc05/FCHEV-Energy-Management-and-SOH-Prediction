% 将四个数组合并成一个矩阵，并保存为 CSV 文件
dataset = [out.data_I, out.data_V, out.data_P, out.data_SOH];
csvwrite('FC_Degradation_WLTC.csv', dataset);
disp('数据集导出成功！');