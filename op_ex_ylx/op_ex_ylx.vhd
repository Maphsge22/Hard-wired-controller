LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_Arith.ALL;
USE IEEE.STD_LOGIC_Unsigned.ALL;

ENTITY op_ex_ylx IS
	PORT(
		SWB 	: IN   STD_LOGIC; 		--ѡ��ͬ�Ŀ���̨ģʽ
		SWA		: IN   STD_LOGIC;		
		SWC		: IN   STD_LOGIC;		
		M   	: OUT  STD_LOGIC;		--M��S���ڿ���ALU�������߼���������
		S   	: OUT  STD_LOGIC_VECTOR(3 DOWNTO 0); --S3,S2,S1,S0	   
		CIN		: OUT  STD_LOGIC;		--��λ
		SEL3    : OUT  STD_LOGIC; 		--SEL3SEL2����ѡ������ALU A�˿ڵļĴ�����SEL2SEL0����ѡ������ALU B�˿ڵļĴ���
		SEL2	: OUT  STD_LOGIC;
		SEL1	: OUT  STD_LOGIC;
		SEL0	: OUT  STD_LOGIC;
		CLR 	: IN   STD_LOGIC;		--��λ,�͵�ƽ��Ч	
		C		: IN   STD_LOGIC;		--��λ��־ 
		Z		: IN   STD_LOGIC;		--���Ϊ���־
		IRH		: IN   STD_LOGIC_VECTOR(3 DOWNTO 0); --IRH7~IRH4��ָ�������
		T3		: IN   STD_LOGIC;		--T3��������
		W1		: IN   STD_LOGIC;		--W1���ĵ�λ
		W2		: IN   STD_LOGIC;		--W2���ĵ�λ
		W3  	: IN   STD_LOGIC;		--W3���ĵ�λ
		SELCTL  : OUT  STD_LOGIC;		--Ϊ1ʱ���ڿ���̨������Ϊ0ʱ�������г���״̬
		DRW    	: OUT  STD_LOGIC;		--Ϊ1ʱ��T3�����ؽ�DBUS�ϵ�����д��SEL3SEL2ѡ�еļĴ���
		ABUS 	: OUT  STD_LOGIC;		--Ϊ1ʱ�������������������DBUS
		SBUS    : OUT  STD_LOGIC;		--Ϊ1ʱ��������������������DBUS
		LIR     : OUT  STD_LOGIC;		--Ϊ1ʱ��DBUS�ϵ�ָ��д��AR
		MBUS    : OUT  STD_LOGIC;		--Ϊ1ʱ��˫�˿�RAM��˿������͵�DBUS
		MEMW    : OUT  STD_LOGIC;		--Ϊ1ʱ��T2Ϊ1�ڼ佫DBUSд��ARָ���Ĵ洢����Ԫ��Ϊ0ʱ���洢��
		LAR     : OUT  STD_LOGIC;		--Ϊ1ʱ��T3�������ؽ�DBUS�ĵ�ַ����AR
		LPC     : OUT  STD_LOGIC; 		--Ϊ1ʱ��T3�������ؽ�DBUS������д��PC
		LDC		: OUT  STD_LOGIC;		--Ϊ1ʱT3�������ر����λ
		LDZ     : OUT  STD_LOGIC;		--Ϊ1ʱT3�������ر�����Ϊ0��־	
		ARINC   : OUT  STD_LOGIC;		--Ϊ1ʱ��T3��������AR��1
		PCINC   : OUT  STD_LOGIC;		--Ϊ1ʱ��T3��������PC��1
		PCADD	: OUT  STD_LOGIC;		--PC����ƫ����
		LONG	: OUT  STD_LOGIC;		--��־ָ���Ҫ���������ĵ�λW3
		SHORT   : OUT  STD_LOGIC;		--��־ָ���Ҫ�ڶ������ĵ�λW2
		STOP	: BUFFER STD_LOGIC		--��ͣʹ�ÿ��Թ۲����̨��ָʾ�Ƶ�
	);
END op_ex_ylx;

ARCHITECTURE behavior OF op_ex_ylx IS 
	SIGNAL ST0,SST0:std_logic;
    SIGNAL SWCBA:std_logic_vector(2 DOWNTO 0);
BEGIN
	SWCBA <= SWC & SWB & SWA;
	PROCESS(IRH,ST0,C,Z,W1,W2,W3,SWCBA,CLR,T3)
	BEGIN
	
	IF(CLR='0') THEN
		ST0 <='0';
	ELSIF(T3'EVENT AND T3='0') THEN
		IF(SST0='1') THEN
			ST0 <='1';
		END IF;
		IF(ST0='1' AND W2='1' AND SWCBA="100") THEN
			ST0 <='0';
		END IF;
	END IF;
	
	   --���ź�����Ĭ��ֵ
	   SHORT 	<= '0';
	   LONG		<= '0';
	   CIN		<= '0';
	   SELCTL   <= '0';
	   ABUS     <= '0';
	   SBUS	    <= '0';
	   MBUS		<= '0';
	   M        <= '0';
	   S        <= "0000";
	   SEL3		<= '0';
	   SEL2		<= '0';
	   SEL1     <= '0'; 
	   SEL0		<= '0';
	   DRW      <= '0';
	   SBUS     <= '0';
	   LIR      <= '0';
	   MEMW     <= '0';
	   LAR      <= '0';
	   PCADD	<= '0';
	   ARINC    <= '0';
	   LPC      <= '0';
	   LDZ		<= '0';
	   LDC		<= '0';
	   STOP	    <= '0';
	   PCINC	<= '0';
	   SST0		<= '0';
	   
	   CASE SWCBA IS
			WHEN "100" =>  --д�Ĵ���
				SST0 <= W2; 
				SBUS <= '1';
				STOP <= '1';
				DRW <= '1';
				SEL3 <= (ST0 AND W1) OR (ST0 AND W2);
				SEL2 <= W2;
				SEL1<= (NOT ST0 AND	W1) OR (ST0 AND W2);
				SEL0 <= W1; 
				SELCTL	 <= '1';
			WHEN "011" =>	--���Ĵ���
				STOP <='1';
				SEL3 <= W2;
				SEL2 <= '0';
				SEL1<= W2;
				SEL0 <='1';
				SELCTL	 <= '1';
			WHEN "010" =>	--���洢��
				SBUS <= NOT ST0 AND W1;
				LAR <= NOT ST0 AND W1;
				SST0 <= NOT ST0 AND W1;
				SHORT <= '1';
				MBUS <= ST0 AND W1;
				ARINC <= W1 AND ST0;
				SELCTL	 <= '1';
				STOP <= W1;
			WHEN "001" =>	--д�洢��
				SST0 <= NOT ST0 AND W1;
				SBUS <= W1;
				STOP <= W1;
				LAR  <= NOT ST0 AND W1;
				SHORT <= W1;
				MEMW <= ST0 AND W1;
				ARINC <= ST0 AND W1;
				SELCTL <= '1';
			WHEN "000" =>   --ִ��ָ���Ϊ�ǲ�����ˮ�ߣ����Բ�������ָ��ͳһ��һ�������Ľ��ĵ�λ������ȡֵ��ִ��ָ��
				---ʹ�ÿ��Դ����õĵ�ַ����ʼִ��ָ��
				SBUS	<=(NOT ST0)AND W1;
				--LPC		<=(NOT ST0)AND W1;
				--SHORT	<=(NOT ST0)AND W1;
				SST0	<=(NOT ST0)AND W1;
				
				LIR <=(((NOT IRH(2) AND IRH(1))OR  
					  (IRH(2)AND NOT IRH(1) AND NOT IRH(0))OR 
					  (NOT IRH(3)AND NOT IRH(2) AND IRH(0))) AND W1)
					  
					  OR(
						  ((NOT IRH(3)AND IRH(2)AND IRH(1) AND IRH(0) AND NOT C)
						  OR  
						  (IRH(3)AND NOT IRH(2) AND NOT IRH(1) AND NOT IRH(0) AND NOT Z)
						  OR
						  (NOT IRH(3) AND NOT IRH(2) AND NOT IRH(1) AND NOT IRH(0) AND ST0)
						  
					  ) AND W1)
					  
					  OR(((NOT IRH(3)AND IRH(2) AND IRH(1))OR  
					  (IRH(3)AND NOT IRH(2) AND NOT IRH(1))) AND W2)
					  
					  OR(NOT IRH(3) AND IRH(2) AND NOT IRH(1) AND IRH(0) AND W2);
				
				PCINC <=(((NOT IRH(2) AND IRH(1))OR  
					  (IRH(2)AND NOT IRH(1) AND NOT IRH(0))OR 
					  (NOT IRH(3)AND NOT IRH(2) AND IRH(0))) AND W1)
					  
					  OR(
						  ((NOT IRH(3)AND IRH(2)AND IRH(1) AND IRH(0) AND NOT C)
						  OR  
						  (IRH(3)AND NOT IRH(2) AND NOT IRH(1) AND NOT IRH(0) AND NOT Z)
						  OR
						  (IRH(3) AND NOT IRH(2) AND IRH(1) AND NOT IRH(0))
						  
					  ) AND W1)
					  
					  OR(((NOT IRH(3)AND IRH(2) AND IRH(1))OR  
					  (IRH(3)AND NOT IRH(2) AND NOT IRH(1))) AND W2)
					  
					  OR(NOT IRH(3) AND IRH(2) AND NOT IRH(1) AND IRH(0) AND W2);
					 
				S(3) <= (
				
						(
							(NOT IRH(2)AND IRH(0))OR  
							(NOT IRH(3)AND NOT IRH(1) AND IRH(0))OR 
							(IRH(3) AND NOT IRH(2) AND IRH(1))OR
							(IRH(3) AND IRH(2) AND NOT IRH(1) AND NOT IRH(0))OR
							(NOT IRH(3) AND IRH(2) AND IRH(1) AND NOT IRH(0))) 
						AND W1)
					
						OR
						(NOT IRH(3) AND IRH(2) AND IRH(1) AND NOT IRH(0) AND W2);
				
				S(2) <= ((IRH(3) AND NOT IRH(2) AND IRH(0))OR
						 (NOT IRH(3) AND IRH(1) AND NOT IRH(0))OR
						 (IRH(3) AND IRH(2) AND NOT IRH(1) AND NOT IRH(0)))AND W1;
						 
				S(1) <= ((((NOT IRH(3)AND IRH(2) AND NOT IRH(1) AND IRH(0))OR  
						(NOT IRH(3)AND IRH(1) AND NOT IRH(0))OR 
						(IRH(3)AND NOT IRH(2) AND IRH(0))) AND W1)
						OR (NOT IRH(2) AND IRH(1))	
						OR(NOT IRH(3) AND IRH(2) AND IRH(1) AND NOT IRH(0) AND W2)
						);
				
				S(0) <=((NOT IRH(3)AND IRH(2) AND IRH(1) AND NOT IRH(0))OR  
						(NOT IRH(2)AND IRH(0))) AND W1;
						
				CIN <= ((IRH(3)AND IRH(2) AND NOT IRH(1) AND NOT IRH(0))OR
						(NOT IRH(3)AND NOT IRH(2) AND NOT IRH(1) AND IRH(0))OR
						(IRH(3)AND NOT IRH(2) AND IRH(1) AND IRH(0)))AND W1;
					
				ABUS <= (
							W1 AND  
							(
								(NOT IRH(2) AND IRH(0))
								OR (NOT IRH(2) AND IRH(1))
								OR (IRH(2) AND NOT IRH(1) AND NOT IRH(0))
								OR (NOT IRH(3) AND IRH(2) AND NOT IRH(1))
								OR (NOT IRH(3) AND IRH(1) AND NOT IRH(0))
							)
						)
						OR
						(
							W2 AND NOT IRH(3) AND IRH(2) AND  IRH(1) AND NOT IRH(0)
						);
				
				DRW <= 	(
							W1 AND 
							(
								(IRH(2) AND NOT IRH(1) AND NOT IRH(0))
								OR (NOT IRH(3) AND NOT IRH(2) AND IRH(0))
								OR (NOT IRH(2) AND IRH(1) AND IRH(0))
								OR (NOT IRH(3) AND NOT IRH(2) AND IRH(1))
							)
						) 
						OR
						(
							W2 AND NOT IRH(3) AND IRH(2) AND NOT IRH(1) AND IRH(0)
						);
				
				LDZ <= W1 AND 
						(
							(IRH(2) AND NOT IRH(1) AND NOT IRH(0))
							OR (NOT IRH(3) AND NOT IRH(2) AND IRH (0))
							OR (NOT IRH(2) AND IRH(1) AND IRH(0))
							OR (NOT IRH(3) AND NOT IRH(2) AND IRH(1))
						);
				
				LDC <= W1 AND
						(
							(IRH(2) AND NOT IRH(1) AND NOT IRH(0))
							OR (NOT IRH(3) AND NOT IRH(2) AND NOT IRH(1) AND IRH(0))
							OR (IRH(3) AND NOT IRH(2) AND IRH(1) AND IRH(0))
							OR (NOT IRH(3) AND NOT IRH(2) AND IRH(1) AND NOT IRH(0) )
						);
						
				M <= (
						W1 AND (
							(NOT IRH(3) AND NOT IRH(2) AND IRH(1) AND IRH(0))
							OR
							(NOT IRH(3) AND IRH(2) AND NOT IRH(1) AND IRH(0))
							OR
							(NOT IRH(3) AND IRH(2) AND IRH(1) AND NOT IRH(0))
							OR
							(IRH(3) AND NOT IRH(2) AND NOT IRH(1) AND IRH(0))
							OR
							(IRH(3) AND NOT IRH(2) AND IRH(1) AND NOT IRH(0))
							)
							
						)
					OR
					(
						W2 AND NOT IRH(3) AND IRH(2) AND IRH(1) AND NOT IRH(0)
					);
				

				
				LAR <=((NOT IRH(3)AND IRH(2)AND NOT IRH(1) AND IRH(0))OR  
				       (NOT IRH(3)AND IRH(2)AND IRH(1) AND NOT IRH(0)) 
					   )AND W1;
	
				LONG <= W2 AND NOT IRH(3) AND IRH(2) AND NOT IRH(1) AND IRH(0);
				
				MBUS <= W2 AND NOT IRH(3) AND IRH(2) AND NOT IRH(1) AND IRH(0);
				
				MEMW <= W2 AND NOT IRH(3) AND IRH(2) AND IRH(1) AND NOT IRH(0);
				
				PCADD <= W1 AND (
					(C AND NOT IRH(3) AND IRH(2) AND IRH(1) AND IRH(0))
					OR (Z AND IRH(3) AND NOT IRH(2) AND NOT IRH(1) AND NOT IRH(0))
					);
				
				LPC <= (W1 AND IRH(3) AND NOT IRH(2) AND NOT IRH(1) AND IRH(0)) OR ((NOT ST0)AND W1);
				
				STOP <= W1 AND IRH(3) AND IRH(2) AND IRH(1) AND NOT IRH(0);
				
				--���һ��short�Բ���
				SHORT <=(
					(
					(NOT IRH(3) AND NOT IRH (2)) OR (NOT IRH(2) AND IRH(1)) OR ( IRH(2) AND NOT IRH(1) AND NOT IRH(0)) OR ( IRH(3) AND IRH(1) AND NOT IRH(0)))
					AND W1)
					OR ((NOT IRH(3) AND IRH(2) AND IRH(1) AND IRH(0))
					AND W1 AND NOT C)
					OR ((IRH(3) AND NOT IRH(2) AND NOT IRH(1) AND NOT IRH(0))
					AND W1 AND NOT Z )
					OR ((NOT ST0)AND W1);
					
			WHEN OTHERS => NULL;
		END CASE;
	END PROCESS;
END behavior;