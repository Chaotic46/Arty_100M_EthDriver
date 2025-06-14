----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/08/2025 09:01:51 PM
-- Design Name: 
-- Module Name: ARP_Generator - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ARP_Generator is
  Generic (
      mac    : std_logic_vector(47 downto 0) := x"000000000000";
      our_ip : std_logic_vector(31 downto 0) := x"00000000"
  );
  Port (
    clk        : in  std_logic;
    rstn       : in  std_logic;
    target_ip  : in  std_logic_vector(31 downto 0);
    
    init_transfer : in std_logic;
    
    m_axi_awaddr  : out std_logic_vector(12 downto 0);
    m_axi_awready : in  std_logic;
    m_axi_awvalid : out std_logic; 
    m_axi_wdata   : out std_logic_vector(31 downto 0);
    m_axi_wready  : in  std_logic;
    m_axi_wvalid  : out std_logic;
    m_axi_wstrb   : out std_logic_vector(3 downto 0);
    m_axi_bresp   : in  std_logic_vector(1 downto 0);
    m_axi_bvalid  : in  std_logic;
    m_axi_bready  : out std_logic;
    m_axi_araddr  : out std_logic_vector(12 downto 0);
    m_axi_arready : in  std_logic;
    m_axi_arvalid : out std_logic;
    m_axi_rdata   : in  std_logic_vector(31 downto 0);
    m_axi_rready  : out std_logic;
    m_axi_rresp   : in  std_logic_vector(1 downto 0);
    m_axi_rvalid  : in  std_logic
  );
end ARP_Generator;

architecture Behavioral of ARP_Generator is
    constant hw_type       : integer := 1;
    constant protocol_type : integer := 16#0800#;
    constant hw_len        : integer := 6;
    constant protocol_len  : integer := 4;
    constant operation     : integer := 1; --request
    
    constant addr_inc   : integer := 4;
    constant upper_addr : integer := 24;
    signal   curr_addr  : integer := 0;
    
    signal init_buf : std_logic := '0';
    
    type state_type is (IDLE, AW, W, B);
    signal state : state_type := IDLE;
begin

    process(clk, rstn)
    begin
        if rstn = '0' then
        
        elsif rising_edge(clk) then
            m_axi_awvalid <= '0';
            m_axi_wvalid  <= '0';
            m_axi_bready  <= '1';
        
            case state is
                when IDLE =>
                    init_buf <= init_transfer;
                    if init_buf = '0' and init_transfer = '1' then
                        state     <= AW;
                        curr_addr <= 0;
                    end if;
  
                when AW =>
                    m_axi_awaddr  <= std_logic_vector(to_unsigned(curr_addr, m_axi_awaddr'length));
                    m_axi_awvalid <= '1';
                    if m_axi_awready = '1' then
                        state <= W;
                    end if;
                    
                when W  =>
                    if curr_addr = 0 then
                        m_axi_wdata <= std_logic_vector(to_unsigned(hw_type, 16)) & std_logic_vector(to_unsigned(protocol_type, 16));
                        
                    elsif curr_addr = 4 then
                        m_axi_wdata <= std_logic_vector(to_unsigned(hw_len, 8)) & std_logic_vector(to_unsigned(protocol_len, 8)) & std_logic_vector(to_unsigned(operation, 16));
                    
                    elsif curr_addr = 8 then
                        m_axi_wdata <= mac(47 downto 16);
                        
                    elsif curr_addr = 12 then
                        m_axi_wdata <= mac(15 downto 0) & our_ip(31 downto 16);
                    
                    elsif curr_addr = 16 then
                        m_axi_wdata <= our_ip(15 downto 0) & x"0000";
                    
                    elsif curr_addr = 20 then
                        m_axi_wdata <= x"00000000";
                    
                    elsif curr_addr = 24 then
                        m_axi_wdata <= target_ip;
                    end if;
                    
                    m_axi_wvalid <= '1';
                    if m_axi_wready = '1' then
                        state <= B;
                    end if;
                
                when B  =>
                    m_axi_bready <= '1';
                    if m_axi_bvalid = '1' then
                        curr_addr <= curr_addr + addr_inc;
                        if curr_addr = upper_addr then
                            state <= IDLE;
                            
                        else
                            state <= AW;
                            
                        end if;
                    end if;
                
            end case;
        end if;
    end process;

end Behavioral;
